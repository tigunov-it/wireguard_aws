data "aws_ami" "latest_ubuntu" {
  //Динамически получаем ami последней версии ubuntu 22.04 ARM
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

resource "aws_instance" "wireguard" {
  ami = data.aws_ami.latest_ubuntu.id
  instance_type = "t4g.small"
  vpc_security_group_ids = [aws_security_group.allow_wireguard.id]
  key_name = var.aws_key_name
  tags = {
    "Name" = "wireguard"
  }
  root_block_device {
    volume_size = 10
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.path_to_private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname wireguard",
    ]
  }

}

resource "cloudflare_record" "wireguard" {
  name    = "wireguard"
  value = aws_instance.wireguard.public_ip
  type    = "A"
  zone_id = var.cloudflare_zone_id
  ttl = 1
#  proxied = true
}

resource "aws_security_group" "allow_wireguard" {
  name        = "allow_wireguard"
  description = "Allow wireguard from all and 22 from my ips"
  # vpc_id      = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.allow_ingress_ports
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = [var.client_ip_address[0], var.client_ip_address[1]]
    }
  }

  ingress {
    from_port   = 51820
    protocol    = "udp"
    to_port     = 51820
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_wireguard"
  }
}

resource "local_file" "inventory" {
  content = templatefile("./inventory.tfpl", {
    host_name = cloudflare_record.wireguard.hostname
  })
  filename   = ".././ansible/hosts_aws.yaml"
  depends_on = [cloudflare_record.wireguard, aws_instance.wireguard]

}