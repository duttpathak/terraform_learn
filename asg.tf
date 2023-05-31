
# # The first step is to create the 
# # ALB itself using the aws_lb resource:

resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

# # The next step is to define a listener for 
# # this ALB using the aws_lb_listener resource:

# # This listener configures the ALB to listen on the default 
# # HTTP port, port 80, use HTTP as the protocol, and send 
# # a simple 404 page as the default response 
# # for requests that don’t match any listener rules.

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

#   # By default, return a simple 404 page
#   default_action {
#     type = "fixed-response"

#     fixed_response {
#       content_type = "text/plain"
#       message_body = "404: page not found"
#       status_code  = 404
#     }
#   }
# }


# resource "aws_security_group" "alb" {
#   name = "terraform-example-alb"
#   # Allow inbound HTTP requests
#   ingress {
#     from_port   = var.server_port
#     to_port     = var.server_port
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   # Allow all outbound requests
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }


# # Next, you need to create a target group for your 
# # ASG using the aws_lb_target_group resource:
# # This target group will health check your Instances 
# # by periodically sending an HTTP request to each Instance 
# # and will consider the Instance “healthy” only if the Instance 
# # returns a response that matches the configured matcher

# resource "aws_lb_target_group" "asg" {
#   name     = "terraform-asg-example"
#   port     = var.server_port
#   protocol = "HTTP"
#   vpc_id   = data.aws_vpc.default.id

#   health_check {
#     path                = "/"
#     protocol            = "HTTP"
#     matcher             = "200"
#     interval            = 15
#     timeout             = 3
#     healthy_threshold   = 2
#     unhealthy_threshold = 2
#   }
# }


# resource "aws_launch_configuration" "example" {
#   image_id      = "ami-0889a44b331db0194"
#   instance_type = "t2.micro"
#   # List of security group IDs to associate with. 
#   security_groups = [aws_security_group.instance.id]
#   # User data to provide when launching the instance. 
#   # Updates to this field will trigger a start/stop of 
#   # EC2 instance by default. 
#   # Line 103 used to create an index.html file and with 
#   # Hello, World in it. 
#   # Line 104  used to run the script even after you log off. 
#   # It continues to run until it is finished. 

#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p ${var.server_port} &
#               EOF
#   # Required when using a launch configuration with an ASG.
#   lifecycle {
#     create_before_destroy = true
#   }
# }
# # creating Auto Scaling Group itself
# # instructs the ASG to use the target group’s health check 
# # to determine whether an Instance is healthy and to automatically replace 
# # Instances if the target group reports them as unhealthy.

# resource "aws_autoscaling_group" "example" {
#   launch_configuration = aws_launch_configuration.example.name
#   vpc_zone_identifier  = data.aws_subnets.default.ids

#   target_group_arns = [aws_lb_target_group.asg.arn]
#   health_check_type = "ELB"

#   min_size = 1
#   max_size = 2

#   tag {
#     key                 = "Name"
#     value               = "terraform-asg-example"
#     propagate_at_launch = true
#   }
# }

# data "aws_vpc" "default" {
#   default = true
# }

# resource "aws_lb_listener_rule" "asg" {
#   listener_arn = aws_lb_listener.http.arn
#   priority     = 100

#   condition {
#     path_pattern {
#       values = ["*"]
#     }
#   }

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.asg.arn
#   }
# }


# data "aws_subnets" "default" {
#   filter {
#     name   = "vpc-id"
#     values = [data.aws_vpc.default.id]
#   }
# }