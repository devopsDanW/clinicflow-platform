variable "env_name" {
  type = string
  description = "Environment name (dev, staging, prod) used in the key alias"
}

variable "deletion_window_in_days" {
  type = number
  description = "KMS key deletion window in days"
}

