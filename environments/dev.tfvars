# aws
aws_region           = "us-east-2"   # or your preferred AWS region
environment          = "development" # or "production", "staging", etc.
project_name         = "chain"
aws_profile          = "terraform"
agave_client_version = "v1.18.10"

# Vpc
vpc = {
  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  name_prefix       = "chain"
}

# Genesis
genesis = {
  bootstrap_validators = [
    {
      identity_pubkey = "~/chain/genesis/bootstrap-validator-identity.json"
      vote_pubkey     = "~/chain/genesis/bootstrap-validator-vote-account.json"
      stake_pubkey    = "~/chain/genesis/bootstrap-validator-stake-account.json"
    }
  ]
  bootstrap_validator_lamports       = 1000000000
  bootstrap_validator_stake_lamports = 1000000000
  cluster_type                       = "development"
  faucet_lamports                    = 1000000000
  faucet_pubkey                      = "~/chain/faucet.json"
  fee_burn_percentage                = 50
  hashes_per_tick                    = "sleep"
  lamports_per_byte_year             = 3480
  ledger_dir                         = "~/chain/ledger"
  max_genesis_archive_unpacked_size  = 1073741824
  rent_burn_percentage               = 100
  rent_exemption_threshold           = 2
  target_lamports_per_signature      = 10000
  target_signatures_per_slot         = 5000
  ticks_per_slot                     = 8
  vote_commission_percentage         = 100
  slots_per_epoch                    = 432000
}

# Bootstrap
bootstrap = {
  identity_keypair     = "~/chain/genesis/bootstrap-validator-identity.json"
  vote_account_keypair = "~/chain/genesis/bootstrap-validator-vote-account.json"
  rpc_port             = 8899
  dynamic_port_range   = "8000-8020"
  gossip_port          = 8001
  rpc_bind_address     = "0.0.0.0"
  log_path             = "validator.log"
  ssh_private_key_path = "~/chain/ssh/id_rsa"
  ssh_public_key_path  = "~/chain/ssh/id_rsa.pub"
  ledger_dir           = "~/chain/ledger"
  root_dir             = "chain"
}
