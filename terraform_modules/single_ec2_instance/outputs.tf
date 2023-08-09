output "public_ip" {
  value       = "curl http://${aws_instance.example.public_ip}"
  description = "The public IP address of the web server"
}
