terraform {
  backend "s3" {
    bucket = "tf-state-nonprod"
    key    = "github.com/duttpathak/terraform_learn/multiple_ec2_instance"
    region = "us-west-2"
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "terraform" {
  key_name   = "multiple_ec2_instance"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBGrHCC95QsUPZozICYflAVpTHe0gcBUDklM3CYmYqUvwHXNSRoZEQWv+HMMNHAekDg3UKG27l+mYCqHiOOHMCmNjPBa6JvwBHTlBI0MHnZao2IZbRph72+3BQ3tIErXQeHhcgjbqQYMsrJRNqof4kUzNztQc6eKWyrMPWtgN7KmhU4efA03tsEwM2cl89YKHxAh5BkKIgbwPXwWyRCSl8N/cBgDNXA3rtHw/gAzunBW2GpB4CQekng9ddShOzn5vgs4ODoDOvyHSl1boj2cMu3/R95c8VgsralyobQ6s4NN7WhjtJmfumbz5kAfD4zAu3UFm5JJBRhjv7hLXIkrq7LKGpgoGkPEGKV01pK61sSYEngesZ3knjQXWanmJqbLdHhH+pzZG2zmGeI5BzOsHuSPdA9+pPXO/glZg5zK8aiSAWjmNGcPS1h1Tfbz4zk8fSGYL7HB0vTVOt4GPkwv9MEUr/hZUsJ+uk1G4t6lrglgrqCY3UvT0JXh0etlPWrtREtYXNYLOoYM44IcJKWGeLSjyIpe0IVyNldvdfWiJe5fnabmCIJhOaep2xClMuCqhkpBIVpzLFcEEqupGoJSH0G5i8xlQ/V9C5mL4xuF3IN1ah+gHNqb4PXGxXpSCxfE3jmgBG0GcBymQPONnjPjOiMwRvx6qCbowhQ+LdyxVfmQ== tarpanpathak720@gmail.com"
}

# The first step in creating an ASG is to 
# create a launch configuration, which specifies 
# how to configure each EC2 Instance in the ASG.
# ami is now image_id, and vpc_security_group_ids 
# is now security_groups), so replace aws_instance 
# with aws_launch_configuration as follows:

resource "aws_launch_configuration" "example" {
  image_id        = "ami-0889a44b331db0194"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.asg.id]
  key_name        = aws_key_pair.terraform.key_name
  user_data       = <<EOF
#!/bin/bash
# set -ex

dnf update -y
# install the http server 
dnf install -y httpd
# starts the http server
systemctl start httpd
EOF
  # Required when using a launch configuration with an ASG.
  lifecycle {
    create_before_destroy = true
  }
}

# Now you can create the ASG itself 
# using the aws_autoscaling_group resource:
# This ASG will run between 1 and 2 EC2 Instances 
# (defaulting to 2 for the initial launch), 
# each tagged with the name terraform-asg-example.

# creating Auto Scaling Group itself
# instructs the ASG to use the target group’s health check 
# to determine whether an Instance is healthy and to automatically replace 
# Instances if the target group reports them as unhealthy.


resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"
  min_size = 1
  max_size = 1
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}

data "aws_vpc" "default" {
  default = true
}

# data source, aws_subnets, 
# to look up the subnets within that VPC:

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# You now have multiple servers, each 
# with its own IP address, but you typically want 
# to give your end users only a single IP to use.
# Create a load balancer.

# The first step is to 
# create the ALB itself using the aws_lb resource:
# You’ll need to tell the aws_lb resource to use this 
# security group via the security_groups argument:

resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

# The next step is to define a listener 
# for this ALB using the aws_lb_listener resource:

# This listener configures the ALB to listen on the default 
# HTTP port, port 80, use HTTP as the protocol, and send 
# a simple 404 page as the default response 
# for requests that don’t match any listener rules.

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

# Note that, by default, all AWS resources, 
# including ALBs, don’t allow any incoming or 
# outgoing traffic, so you need to create a new security 
# group specifically for the ALB. This security group should 
# allow incoming requests on port 80 so that you can access the 
# load balancer over HTTP, and allow outgoing requests on all ports 
# so that the load balancer can perform health checks:


resource "aws_security_group" "asg" {
  name = "terraform-example-asg"
  ingress {
    from_port   = var.server_port_in
    to_port     = var.server_port_in
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # egress is for outgoing requests.
  # outgoing means from the instance 
  # connect to something
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  # Allow inbound HTTP requests
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Next, you need to create a target group for your 
# ASG using the aws_lb_target_group resource:

resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


# Finally, it’s time to tie all these pieces together 
# by creating listener rules using the 
# aws_lb_listener_rule resource:

# The preceding code adds a listener rule that sends requests 
# that match any path to the target group that contains your ASG.

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}




# replace the old public_ip output of the single EC2 Instance you had 
# before with an output that shows the DNS name of the ALB:
output "alb_dns_name" {
  value       = "curl http://${aws_lb.example.dns_name}"
  description = "The domain name of the load balancer"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "server_port_in" {
  description = "The port for incoming HTTP requests"
  type        = number
  default     = 22
}

variable "server_port_out" {
  description = "The port for outgoing HTTP requests"
  type        = number
  default     = 65535
}