variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Base name for the resources"
  type        = string
  default     = "fargate-ecs-app"
}

variable "availability_zones" {
  description = "Availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "frontend_image" {
  description = "Container image for the React frontend"
  type        = string
  default     = ""
}

variable "backend_image" {
  description = "Container image for the FastAPI backend"
  type        = string
  default     = ""
}

variable "frontend_ecr_repository_name" {
  description = "Name of the frontend ECR repository"
  type        = string
  default     = "fargate-ecs-app-frontend"
}

variable "backend_ecr_repository_name" {
  description = "Name of the backend ECR repository"
  type        = string
  default     = "fargate-ecs-app-backend"
}

variable "database_name" {
  description = "RDS database name"
  type        = string
  default     = "tododb"
}

variable "database_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "database_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}
