variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "container_image" {
  description = "Container image to run"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC identifier"
  type        = string
}

variable "public_subnets" {
  description = "Public subnets for ALB"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets for service"
  type        = list(string)
}

variable "create_alb" {
  description = "Whether to create an application load balancer"
  type        = bool
  default     = false
}

variable "ingress_security_group_ids" {
  description = "Additional security groups allowed to reach the service"
  type        = list(string)
  default     = []
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Subnets for the ECS service"
  type        = list(string)
  default     = []
}

variable "alb_ingress_cidrs" {
  description = "CIDR blocks allowed to reach the ALB"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "alb_ingress_security_group_ids" {
  description = "Security groups allowed to reach the ALB"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether tasks should receive public IP addresses"
  type        = bool
  default     = false
}

variable "container_environment" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "alb_internal" {
  description = "Whether the ALB should be internal"
  type        = bool
  default     = false
}

variable "execution_role_arn" {
  description = "Existing IAM role ARN to use for ECS task execution. Leave empty to create one."
  type        = string
  default     = ""
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch log group for this service"
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "CloudWatch log group name. Leave empty to use default naming."
  type        = string
  default     = ""
}
