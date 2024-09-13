variable "aws_region" { type = string }
variable "environment" { type = string }
variable "project_name" { type = string }
variable "aws_profile" { type = string }
variable "agave_client_version" { type = string }

variable "genesis" {
  type = object({
    bootstrap_validators = list(object({
      identity_pubkey = string
      vote_pubkey     = string
      stake_pubkey    = string
    }))
    bootstrap_validator_lamports       = number
    bootstrap_validator_stake_lamports = number
    cluster_type                       = string
    faucet_lamports                    = number
    faucet_pubkey                      = string
    fee_burn_percentage                = number
    hashes_per_tick                    = string
    lamports_per_byte_year             = number
    ledger_dir                         = string
    max_genesis_archive_unpacked_size  = number
    rent_burn_percentage               = number
    rent_exemption_threshold           = number
    target_lamports_per_signature      = number
    target_signatures_per_slot         = number
    ticks_per_slot                     = number
    slots_per_epoch                    = number
    vote_commission_percentage         = number
  })
  default = null
}

variable "bootstrap" {
  type = object({
    ssh_private_key_path = string
    ssh_public_key_path  = string
    ledger_dir           = string
    identity_keypair     = string
    vote_account_keypair = string
    rpc_port             = number
    dynamic_port_range   = string
    gossip_port          = number
    rpc_bind_address     = string
    log_path             = string
    root_dir             = string
  })
  default = null
}

variable "vpc" {
  type = object({
    name_prefix       = string
    vpc_cidr          = string
    subnet_cidr       = string
    availability_zone = string
  })
  default = null
}