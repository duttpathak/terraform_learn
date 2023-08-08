provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "terraform" {
  key_name   = var.key_name
  public_key = var.public_key
}


# The first step in creating an ASG is to 
# create a launch configuration, which specifies 
# how to configure each EC2 Instance in the ASG.
# ami is now image_id, and vpc_security_group_ids 
# is now security_groups), so replace aws_instance 
# with aws_launch_configuration as follows:

resource "aws_launch_configuration" "example" {
  image_id        = var.image_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.terraform.key_name
  user_data       = var.user_data
  security_groups = [aws_security_group.asg.id]
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
  health_check_type    = var.health_check_type
  min_size             = var.min_size
  max_size             = var.max_size
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
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
  name               = var.lb_name
  load_balancer_type = var.load_balancer_type
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

# The next step is to define a listener 
# for this ALB using the aws_lb_listener resource:

# This listener configures the ALB to listen on the default 
# HTTP port, port 80, use HTTP as the protocol, and send 
# a simple 404 page as the default response 
# for requests that don’t match any listener rules.

# resource "type" "name"


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = var.http_port
  protocol          = var.alb_protocol
  # By default, return a simple 404 page
  default_action {          # variable
    type = "fixed-response" # nested map variable

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
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
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
    from_port   = var.http_port
    to_port     = var.http_port
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
  name     = var.lb_target_group_name
  port     = var.http_port
  protocol = var.alb_protocol
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = var.health_check_path # "/"
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }
}


# Finally, it’s time to tie all these pieces together 
# by creating listener rules using the 
# aws_lb_listener_rule resource:

# The preceding code adds a listener rule that sends requests 
# that match any path to the target group that contains your ASG.

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = var.alb_listener_rule_priority

  # action argument that is set to a type in a variable and has a path.

  action {
    type             = var.lb_listener_rule_action_type
    target_group_arn = aws_lb_target_group.asg.arn #resource reference
  }

  # condition { # variable
  #   path_pattern {
  #     values = ["*"]
  #   }
  # }

  dynamic "condition" {
    # for each condition in the routing condition 
    # variable look at the value if the field is 
    # path-pattern then set to condition value 
    for_each = [for condition in var.routing_condition : condition.values if condition.field == "path-pattern"]
    content {
      path_pattern {
        values = condition.value
      }
    }
  }
}

