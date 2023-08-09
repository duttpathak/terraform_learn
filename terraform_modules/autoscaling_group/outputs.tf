output "alb_dns_name" {
  value       = "curl http://${aws_lb.example.dns_name}"
  description = "The domain name of the load balancer"
}
