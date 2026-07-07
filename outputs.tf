output "frontend_alb_dns_name" {
  description = "DNS name of the public application load balancer"
  value       = module.frontend.alb_dns_name
}

output "database_endpoint" {
  description = "RDS endpoint for the data tier"
  value       = module.database.endpoint
}
