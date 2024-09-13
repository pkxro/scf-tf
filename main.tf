terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
    }
  }
}


module "genesis" {
  source = "./modules/genesis"

  bootstrap_validators               = var.genesis.bootstrap_validators
  bootstrap_validator_lamports       = var.genesis.bootstrap_validator_lamports
  bootstrap_validator_stake_lamports = var.genesis.bootstrap_validator_stake_lamports
  cluster_type                       = var.genesis.cluster_type
  faucet_lamports                    = var.genesis.faucet_lamports
  faucet_pubkey                      = var.genesis.faucet_pubkey
  fee_burn_percentage                = var.genesis.fee_burn_percentage
  hashes_per_tick                    = var.genesis.hashes_per_tick
  lamports_per_byte_year             = var.genesis.lamports_per_byte_year
  ledger_dir                         = var.genesis.ledger_dir
  max_genesis_archive_unpacked_size  = var.genesis.max_genesis_archive_unpacked_size
  rent_burn_percentage               = var.genesis.rent_burn_percentage
  rent_exemption_threshold           = var.genesis.rent_exemption_threshold
  target_lamports_per_signature      = var.genesis.target_lamports_per_signature
  target_signatures_per_slot         = var.genesis.target_signatures_per_slot
  ticks_per_slot                     = var.genesis.ticks_per_slot
  slots_per_epoch                    = var.genesis.slots_per_epoch
  vote_commission_percentage         = var.genesis.vote_commission_percentage
}

module "bootstrap" {
  source = "./modules/bootstrap"

  ssh_private_key_path = var.bootstrap.ssh_private_key_path
  ssh_public_key_path  = var.bootstrap.ssh_public_key_path
  ledger_dir           = var.bootstrap.ledger_dir
  identity_keypair     = var.bootstrap.identity_keypair
  vote_account_keypair = var.bootstrap.vote_account_keypair
  rpc_port             = var.bootstrap.rpc_port
  dynamic_port_range   = var.bootstrap.dynamic_port_range
  gossip_port          = var.bootstrap.gossip_port
  rpc_bind_address     = var.bootstrap.rpc_bind_address
  log_path             = var.bootstrap.log_path
  root_dir             = var.bootstrap.root_dir
  agave_client_version = var.agave_client_version

  vpc = {
    name_prefix       = var.vpc.name_prefix
    vpc_cidr          = var.vpc.vpc_cidr
    subnet_cidr       = var.vpc.subnet_cidr
    availability_zone = var.vpc.availability_zone
  }
}