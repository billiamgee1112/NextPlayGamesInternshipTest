output "alb_dns_name" {
  value       = aws_lb.app.dns_name
  description = "ALB DNS name to access services"
}

output "python_service_arn" {
  value       = aws_ecs_service.python.arn
  description = "ARN for the Python ECS service"
}

output "node_service_arn" {
  value       = aws_ecs_service.node.arn
  description = "ARN for the Node ECS service"
}