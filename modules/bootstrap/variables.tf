variable "ssh_private_key_path" {
  description = "Path to the private SSH key file"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key file"
  type        = string
}

variable "root_dir" {
  description = "Root directory"
  type        = string
}

variable "ledger_dir" {
  description = "Directory for the ledger"
  type        = string
}

variable "identity_keypair" {
  description = "Path to the identity keypair"
  type        = string
}

variable "vote_account_keypair" {
  description = "Path to the vote account keypair"
  type        = string
}

variable "rpc_port" {
  description = "RPC port"
  type        = number
  default     = "8899"
}

variable "dynamic_port_range" {
  description = "Dynamic port range"
  type        = string
  default     = "8000-8014"
}

variable "gossip_port" {
  description = "Gossip port"
  type        = number
  default     = 8001
}

variable "rpc_bind_address" {
  description = "RPC bind address"
  type        = string
  default     = "0.0.0.0"
}

variable "log_path" {
  description = "Path for log files"
  type        = string
}

variable "agave_client_version" {
  description = "Agave client version"
  type        = string
}

variable "vpc" {
  type = object({
    name_prefix       = string
    vpc_cidr          = string
    subnet_cidr       = string
    availability_zone = string
  })
}