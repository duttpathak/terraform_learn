
output "public_ip" {
  value       = "curl http://${aws_instance.example.public_ip}"
  description = "The public IP address of the web server"
}



# # replace the old public_ip output of the single EC2 Instance you had 
# # before with an output that shows the DNS name of the ALB:

# output "alb_dns_name" {
#   value       = aws_lb.example.dns_name
#   description = "The domain name of the load balancer"
# }