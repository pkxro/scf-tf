variable "bootstrap_validators" {
  description = "List of bootstrap validators, each as a map with identity_pubkey, vote_pubkey, and stake_pubkey"
  type = list(object({
    identity_pubkey = string
    vote_pubkey     = string
    stake_pubkey    = string
  }))
}

variable "bootstrap_validator_lamports" {
  description = "Number of lamports for each bootstrap validator"
  type        = number
  default     = 1000000000
}

variable "bootstrap_validator_stake_lamports" {
  description = "Number of stake lamports for each bootstrap validator"
  type        = number
  default     = 500000000000
}

variable "slots_per_epoch" {
  description = "Number of slots per epoch"
  type        = number
  default     = 432000
}

variable "cluster_type" {
  description = "Type of the cluster"
  type        = string
  default     = "devnet"
}

variable "faucet_lamports" {
  description = "Number of lamports for the faucet"
  type        = number
  default     = "1000000000000"

}

variable "faucet_pubkey" {
  description = "Public key of the faucet"
  type        = string
}

variable "fee_burn_percentage" {
  description = "Percentage of fees to burn"
  type        = number
  default     = 50
}

variable "hashes_per_tick" {
  description = "Number of hashes per tick (can be 'auto' or 'sleep')"
  type        = string
  default     = "sleep"
}

variable "lamports_per_byte_year" {
  description = "Number of lamports per byte per year for rent"
  type        = number
  default     = "3480"
}

variable "ledger_dir" {
  description = "Directory for the ledger"
  type        = string
}

variable "max_genesis_archive_unpacked_size" {
  description = "Maximum size of unpacked genesis archive"
  type        = number
  default     = "10485760"
}

variable "rent_burn_percentage" {
  description = "Percentage of rent to burn"
  type        = number
  default     = 50
}

variable "rent_exemption_threshold" {
  description = "Rent exemption threshold"
  type        = number
  default     = 2
}

variable "target_lamports_per_signature" {
  description = "Target lamports per signature"
  type        = number
  default     = 10000
}

variable "target_signatures_per_slot" {
  description = "Target signatures per slot"
  type        = number
  default     = 20000
}

variable "ticks_per_slot" {
  description = "Number of ticks per slot"
  type        = number
  default     = 64
}

variable "vote_commission_percentage" {
  description = "Vote commission percentage"
  type        = number
  default     = 100
}