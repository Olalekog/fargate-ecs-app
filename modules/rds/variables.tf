variable "name" {
  description = "Name of the database instance"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "username" {
  description = "Database username"
  type        = string
}

variable "password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnets" {
  description = "Private subnets for the database"
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to access the database"
  type        = list(string)
  default     = []
}
