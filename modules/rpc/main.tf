# locals {
#   full_ledger_path = var.ledger_dir
#   remote_home_dir  = "/home/ubuntu"
#   local_home_dir   = "~/"
# }

# module "aws_vpc" {
#   source            = "../vpc"
#   name_prefix       = var.vpc.name_prefix
#   availability_zone = var.vpc.availability_zone
#   vars = {
#     vpc_cidr    = var.vpc.vpc_cidr
#     subnet_cidr = var.vpc.subnet_cidr
#   }
# }

# resource "aws_key_pair" "bootstrap_deployer" {
#   key_name   = "rpc-deployer-key"
#   public_key = file(var.ssh_public_key_path)
# }

# resource "aws_instance" "chain_rpc" {
#   ami                         = "ami-0731755794ada3662"
#   instance_type               = "r6a.8xlarge"
#   key_name                    = aws_key_pair.bootstrap_deployer.key_name
#   subnet_id                   = module.aws_vpc.subnet_id
#   vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
#   associate_public_ip_address = true
  
# tags = {
#     Name = "chain-rpc"
# }

#   user_data = <<-EOF
#     #!/bin/bash
#     exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
#     echo "BEGIN USER DATA SCRIPT"
#     echo "Adding SSH public key to authorized_keys..."
#     mkdir -p /home/ubuntu/.ssh
#     echo "${file(var.ssh_public_key_path)}" >> /home/ubuntu/.ssh/authorized_keys
#     # echo "Setting correct permissions..."
#     chmod 700 /home/ubuntu/.ssh
#     chmod 600 /home/ubuntu/.ssh/authorized_keys
#     chown -R ubuntu:ubuntu /home/ubuntu/.ssh
#     echo "Restarting SSH service..."
#     systemctl restart sshd
#     echo "END USER DATA SCRIPT"
#   EOF

# }

