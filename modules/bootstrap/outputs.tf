output "instance_public_ip" {
  value = aws_instance.chain_bootstrap_validator.public_ip
}

output "ssh_command" {
  value = "ssh -i ${var.ssh_private_key_path} ec2-user@${aws_instance.chain_bootstrap_validator.public_ip}"
}