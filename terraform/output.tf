output "instance_public_ip" {
  value = aws_instance.wireguard.public_ip
}

output "cloudflare_info" {
  value = cloudflare_record.wireguard
}
