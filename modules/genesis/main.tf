resource "null_resource" "solana_genesis" {
  triggers = {
    bootstrap_validators               = jsonencode(var.bootstrap_validators)
    bootstrap_validator_lamports       = var.bootstrap_validator_lamports
    bootstrap_validator_stake_lamports = var.bootstrap_validator_stake_lamports
    cluster_type                       = var.cluster_type
    faucet_lamports                    = var.faucet_lamports
    faucet_pubkey                      = var.faucet_pubkey
    slots_per_epoch                    = var.slots_per_epoch
  }

  provisioner "local-exec" {
    command = <<-EOT
      solana-genesis \
      ${join(" ", [for v in var.bootstrap_validators : "--bootstrap-validator ${v.identity_pubkey} ${v.vote_pubkey} ${v.stake_pubkey}"])} \
      --bootstrap-validator-lamports ${var.bootstrap_validator_lamports} \
      --slots-per-epoch ${var.slots_per_epoch} \
      --bootstrap-validator-stake-lamports ${var.bootstrap_validator_stake_lamports} \
      --cluster-type ${var.cluster_type} \
      --faucet-lamports ${var.faucet_lamports} \
      --faucet-pubkey ${var.faucet_pubkey} \
      --fee-burn-percentage ${var.fee_burn_percentage} \
      --hashes-per-tick ${var.hashes_per_tick} \
      --lamports-per-byte-year ${var.lamports_per_byte_year} \
      --ledger ${var.ledger_dir} \
      --max-genesis-archive-unpacked-size ${var.max_genesis_archive_unpacked_size} \
      --rent-burn-percentage ${var.rent_burn_percentage} \
      --rent-exemption-threshold ${var.rent_exemption_threshold} \
      --target-lamports-per-signature ${var.target_lamports_per_signature} \
      --target-signatures-per-slot ${var.target_signatures_per_slot} \
      --ticks-per-slot ${var.ticks_per_slot} \
      --vote-commission-percentage ${var.vote_commission_percentage} \
      --enable-warmup-epochs
    EOT
  }
}

