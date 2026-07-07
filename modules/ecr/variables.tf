variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "create_repository" {
  description = "Whether Terraform should create the repository"
  type        = bool
  default     = true
}
