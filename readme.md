# Wireguard VPN
Create and deploy your VPN server.

## Requirements
1. Ansible
2. Terraform
3. AWS account
4. CloudFlare account (optional)


## Deploy и CI/CD

```
mv ./terraform/terraform.tfvars.example ./terraform/terraform.tfvars
echo 'your vars' > terraform.tfvars
```

```
terraform apply
```
```
ansible-playbook -i hosts_aws.yaml playbook.yaml --private-key=~/.ssh/id_rsa --user=ubuntu
```

## Sources

https://github.com/linuxserver/docker-wireguard 

