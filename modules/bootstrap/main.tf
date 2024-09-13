locals {
  full_ledger_path = var.ledger_dir
  remote_home_dir  = "/home/ubuntu"
  local_home_dir   = "~/"
}

module "aws_vpc" {
  source            = "../vpc"
  name_prefix       = var.vpc.name_prefix
  availability_zone = var.vpc.availability_zone
  vars = {
    vpc_cidr    = var.vpc.vpc_cidr
    subnet_cidr = var.vpc.subnet_cidr
  }
}

resource "aws_key_pair" "bootstrap_deployer" {
  key_name   = "bootstrap-deployer-key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Be cautious with this setting in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_instance" "chain_bootstrap_validator" {
  ami                         = "ami-0731755794ada3662"
  instance_type               = "r6a.8xlarge"
  key_name                    = aws_key_pair.bootstrap_deployer.key_name
  subnet_id                   = module.aws_vpc.subnet_id
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "chain-bootstrap-validator"
  }

  user_data = <<-EOF
    #!/bin/bash
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
    echo "BEGIN USER DATA SCRIPT"
    echo "Adding SSH public key to authorized_keys..."
    mkdir -p /home/ubuntu/.ssh
    echo "${file(var.ssh_public_key_path)}" >> /home/ubuntu/.ssh/authorized_keys
    echo "Setting correct permissions..."
    chmod 700 /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/authorized_keys
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh
    echo "Restarting SSH service..."
    systemctl restart sshd
    echo "END USER DATA SCRIPT"
  EOF

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y curl git",

      # Install Rust
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y",
      "echo 'source $HOME/.cargo/env' >> ~/.bashrc",
      "source $HOME/.cargo/env",

      # Install Solana
      "sh -c \"$(curl -sSfL https://release.anza.xyz/${var.agave_client_version}/install)\"",
      "echo 'export PATH=\"$HOME/.local/share/solana/install/active_release/bin:$PATH\"' >> ~/.bashrc",
      "echo 'export PATH=\"/home/ubuntu/.local/share/solana/install/active_release/bin:$PATH\"'",
      "source ~/.bashrc",

      # Create necessary directories
      "mkdir -p ${local.remote_home_dir}/chain ${local.remote_home_dir}/chain/ledger ${local.remote_home_dir}/chain/logs",

    ]
  }

  provisioner "file" {
    source      = var.ledger_dir
    destination = "${local.remote_home_dir}/${var.root_dir}"
  }

  provisioner "file" {
    source      = var.identity_keypair
    destination = "${local.remote_home_dir}/${var.root_dir}/identity.json"
  }

  provisioner "file" {
    source      = var.vote_account_keypair
    destination = "${local.remote_home_dir}/${var.root_dir}/vote-account.json"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "echo 'Starting provisioning process' > ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",

      "mkdir -p ${local.remote_home_dir}/${var.root_dir}/logs >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",
      "chmod 755 ${local.remote_home_dir}/${var.root_dir}/logs >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",

      "echo 'Performing Solana system tuning...' >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",

      "cat <<'EOF' > ${local.remote_home_dir}/${var.root_dir}/tune_system.sh",
      "#!/bin/bash",
      "set -ex",
      "echo 'net.core.rmem_default = 134217728' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.core.rmem_max = 134217728' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.core.wmem_default = 134217728' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.core.wmem_max = 134217728' | sudo tee -a /etc/sysctl.conf",
      "echo 'vm.max_map_count = 1000000' | sudo tee -a /etc/sysctl.conf",
      "echo 'fs.nr_open = 1000000' | sudo tee -a /etc/sysctl.conf",
      "echo '* soft nofile 1000000' | sudo tee -a /etc/security/limits.conf",
      "echo '* hard nofile 1000000' | sudo tee -a /etc/security/limits.conf",
      "echo 'root soft nofile 1000000' | sudo tee -a /etc/security/limits.conf",
      "echo 'root hard nofile 1000000' | sudo tee -a /etc/security/limits.conf",
      "sudo sysctl -p",
      "echo 'DefaultLimitNOFILE=1000000' | sudo tee -a /etc/systemd/system.conf",
      "echo 'DefaultLimitNOFILE=1000000' | sudo tee -a /etc/systemd/user.conf",
      "sudo systemctl daemon-reload",
      "EOF",

      "chmod +x ${local.remote_home_dir}/${var.root_dir}/tune_system.sh",
      "sudo ${local.remote_home_dir}/${var.root_dir}/tune_system.sh >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",

      # Apply changes to current session
      "sudo prlimit --nofile=1000000:1000000 --pid $$",
      "ulimit -n 1000000",

      "cat <<'EOF' > ${local.remote_home_dir}/${var.root_dir}/start_validator.sh",
      "#!/bin/bash",
      "set -ex",
      "export PATH=$HOME/.local/share/solana/install/active_release/bin:$PATH",
      "ulimit -n 1000000", # Set file descriptor limit for this script
      "agave-validator \\",
      "  --ledger \"${local.remote_home_dir}/${var.root_dir}/ledger\" \\",
      "  --identity \"${local.remote_home_dir}/${var.root_dir}/identity.json\" \\",
      "  --vote-account \"${local.remote_home_dir}/${var.root_dir}/vote-account.json\" \\",
      "  --rpc-port ${var.rpc_port} \\",
      "  --dynamic-port-range ${var.dynamic_port_range} \\",
      "  --gossip-port ${var.gossip_port} \\",
      "  --rpc-bind-address ${var.rpc_bind_address} \\",
      "  --enable-rpc-transaction-history \\",
      "  --enable-cpi-and-log-storage \\",
      "  --log \"${local.remote_home_dir}/${var.root_dir}/logs/validator.log\" \\",
      "  --wal-recovery-mode skip_any_corrupted_record \\",
      "  --no-wait-for-vote-to-start-leader",
      "EOF",

      "chmod +x ${local.remote_home_dir}/${var.root_dir}/start_validator.sh",

      "nohup sudo -E bash -c 'ulimit -n 1000000 && ${local.remote_home_dir}/${var.root_dir}/start_validator.sh' > ${local.remote_home_dir}/${var.root_dir}/logs/nohup.out 2> ${local.remote_home_dir}/${var.root_dir}/logs/nohup.err < /dev/null &",

      "sleep 10",
      "if pgrep -f agave-validator > /dev/null; then",
      "  echo 'Validator started successfully' >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",
      "else",
      "  echo 'Failed to start validator' >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",
      "  echo 'Contents of nohup.out:' >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",
      "  cat ${local.remote_home_dir}/${var.root_dir}/logs/nohup.out >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",
      "  echo 'Contents of nohup.err:' >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",
      "  cat ${local.remote_home_dir}/${var.root_dir}/logs/nohup.err >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1",
      "  exit 1",
      "fi",

      "echo 'Provisioning process completed successfully' >> ${local.remote_home_dir}/${var.root_dir}/logs/provision.log 2>&1"
    ]
  }
}