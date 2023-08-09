# remote state terraform buckets 
terraform {
  backend "s3" {
    bucket = "tf-state-nonprod"
    key    = "github.com/duttpathak/terraform_learn/ec2_instance"
    region = "us-west-2"
  }
}

# module call 
# has to be parent directory with the word modules in it. 
# quotes makes string
module "ec2-instance" {
  source              = "../terraform_modules/single_ec2_instance"
  ami                 = var.ami
  key_name            = var.key_name
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBGrHCC95QsUPZozICYflAVpTHe0gcBUDklM3CYmYqUvwHXNSRoZEQWv+HMMNHAekDg3UKG27l+mYCqHiOOHMCmNjPBa6JvwBHTlBI0MHnZao2IZbRph72+3BQ3tIErXQeHhcgjbqQYMsrJRNqof4kUzNztQc6eKWyrMPWtgN7KmhU4efA03tsEwM2cl89YKHxAh5BkKIgbwPXwWyRCSl8N/cBgDNXA3rtHw/gAzunBW2GpB4CQekng9ddShOzn5vgs4ODoDOvyHSl1boj2cMu3/R95c8VgsralyobQ6s4NN7WhjtJmfumbz5kAfD4zAu3UFm5JJBRhjv7hLXIkrq7LKGpgoGkPEGKV01pK61sSYEngesZ3knjQXWanmJqbLdHhH+pzZG2zmGeI5BzOsHuSPdA9+pPXO/glZg5zK8aiSAWjmNGcPS1h1Tfbz4zk8fSGYL7HB0vTVOt4GPkwv9MEUr/hZUsJ+uk1G4t6lrglgrqCY3UvT0JXh0etlPWrtREtYXNYLOoYM44IcJKWGeLSjyIpe0IVyNldvdfWiJe5fnabmCIJhOaep2xClMuCqhkpBIVpzLFcEEqupGoJSH0G5i8xlQ/V9C5mL4xuF3IN1ah+gHNqb4PXGxXpSCxfE3jmgBG0GcBymQPONnjPjOiMwRvx6qCbowhQ+LdyxVfmQ== tarpanpathak720@gmail.com"
  security_group_name = "terraform-example-instance"
  vpc_id              = var.vpc_id
  user_data           = <<-EOF
  #!/bin/bash
  set -ex

  dnf update -y
  # install the http server 
  dnf install -y httpd
  # starts the http server
  systemctl start httpd
  EOF
}

module "asg" {
  source              = "../terraform_modules/autoscaling_group"
  image_id            = var.ami
  key_name            = var.key_name
  public_key          = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBGrHCC95QsUPZozICYflAVpTHe0gcBUDklM3CYmYqUvwHXNSRoZEQWv+HMMNHAekDg3UKG27l+mYCqHiOOHMCmNjPBa6JvwBHTlBI0MHnZao2IZbRph72+3BQ3tIErXQeHhcgjbqQYMsrJRNqof4kUzNztQc6eKWyrMPWtgN7KmhU4efA03tsEwM2cl89YKHxAh5BkKIgbwPXwWyRCSl8N/cBgDNXA3rtHw/gAzunBW2GpB4CQekng9ddShOzn5vgs4ODoDOvyHSl1boj2cMu3/R95c8VgsralyobQ6s4NN7WhjtJmfumbz5kAfD4zAu3UFm5JJBRhjv7hLXIkrq7LKGpgoGkPEGKV01pK61sSYEngesZ3knjQXWanmJqbLdHhH+pzZG2zmGeI5BzOsHuSPdA9+pPXO/glZg5zK8aiSAWjmNGcPS1h1Tfbz4zk8fSGYL7HB0vTVOt4GPkwv9MEUr/hZUsJ+uk1G4t6lrglgrqCY3UvT0JXh0etlPWrtREtYXNYLOoYM44IcJKWGeLSjyIpe0IVyNldvdfWiJe5fnabmCIJhOaep2xClMuCqhkpBIVpzLFcEEqupGoJSH0G5i8xlQ/V9C5mL4xuF3IN1ah+gHNqb4PXGxXpSCxfE3jmgBG0GcBymQPONnjPjOiMwRvx6qCbowhQ+LdyxVfmQ== tarpanpathak720@gmail.com"
  security_group_name = "terraform-asg-example"
  health_check_type   = "ELB"
  vpc_id              = var.vpc_id
  health_check_path   = "/"
  tags = {
    Name = "terraform_asg"
  }
  user_data = <<-EOF
#!/bin/bash
set -ex

dnf update -y
# install the http server 
dnf install -y httpd
# starts the http server
systemctl start httpd
EOF
}

variable "ami" {
  default = "ami-0889a44b331db0194"
}

variable "key_name" {
  default = "aws_key_pair"
}

variable "vpc_id" {
  default = "vpc-2a7d1051"
}

output "ec2_instance_ip" {
  value       = "curl http://${module.ec2-instance.public_ip}"
  description = "The public IP of the EC2 instance."
}

output "alb_dns_name" {
  value       = "curl http://${module.asg.alb_dns_name}"
  description = "The domain name of the load balancer"
}

