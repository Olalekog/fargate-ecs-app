output "repository_url" {
  description = "URL of the ECR repository"
  value       = var.create_repository ? aws_ecr_repository.this[0].repository_url : data.aws_ecr_repository.existing[0].repository_url
}
