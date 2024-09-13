variable "vars" {
  type        = map(any)
  description = "Map of all variables passed from the root module"
}

variable "name_prefix" {
  description = "Prefix to be used in the naming of some of the created resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "The AZ where the subnet will be created"
  type        = string
}
