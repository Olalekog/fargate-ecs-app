output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = var.create_alb ? aws_lb.this[0].dns_name : null
}

output "task_security_group_id" {
  description = "Security group attached to the task"
  value       = aws_security_group.task.id
}
