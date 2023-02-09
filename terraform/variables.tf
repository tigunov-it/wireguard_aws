variable "cloudflare_api_token" {}

variable "cloudflare_zone_id" {}

variable "client_ip_address" {}

variable "allow_ingress_ports" {}

variable "path_to_private_key" {}

variable "aws_key_name" {}

variable "aws_region" {
  type        = string
  description = "Please write aws region, where do you want to create server"
  default = "ca-central-1"
}
