variable "name" {
  description = "value"
  type        = string
}

variable "description" {
  description = "Description record to KMS key"
  type        = string
  default     = "Default description to KMS key"
}

variable "deletion_window_in_days" {
  description = "Deletition period of KMS key in days"
  type        = number
  default     = 15
}