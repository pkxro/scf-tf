output "genesis_complete" {
  description = "Indicates whether the genesis process has completed"
  value       = null_resource.solana_genesis.id
}

output "ledger_dir" {
  description = "Directory where the ledger is stored"
  value       = var.ledger_dir
}