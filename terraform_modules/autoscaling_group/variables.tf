variable "image_id" {
  description = <<-EOF
  (Optional) AMI to use for the 
  instance. Required unless launch_template is specified 
  and the Launch Template specifes an AMI. If an AMI is 
  specified in the Launch Template, setting ami will 
  override the AMI specified in the Launch Template.
  EOF
  type        = string
  default     = null
}

variable "instance_type" {
  description = <<-EOF
  (Optional) Instance type to use for the instance. 
  Required unless launch_template is specified and the 
  Launch Template specifies an instance type. 
  If an instance type is specified in the Launch Template, 
  setting instance_type will override the instance type 
  specified in the Launch Template. Updates to this field 
  will trigger a stop/start of the EC2 instance.
  EOF
  type        = string
  default     = "t2.micro"
}

variable "user_data" {
  description = <<-EOF
  (Optional) User data to provide when launching the 
  instance. Do not pass gzip-compressed data via this 
  argument. Updates to this field will trigger a stop/start of the EC2 instance by 
  default. If the user_data_replace_on_change is set then 
  updates to this field will trigger a destroy and recreate.
  EOF
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = <<-EOF
  (Optional) When used in combination 
  with user_data or user_data_base64 will trigger a destroy 
  and recreate when set to true. 
  Defaults to false if not set.
  EOF
  type        = bool
  default     = false
}

variable "tags" {
  description = <<-EOF
  (Optional) Map of tags to assign to the resource. 
  Note that these tags apply to the instance and not 
  block storage devices. If configured with a provider 
  default_tags configuration block present, tags with 
  matching keys will overwrite those defined at the 
  provider-level.
  EOF
  type        = map(string)
  default     = {}
}

variable "security_group_name" {
  description = "name of the security group for the ec2 instance"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region to deploy instance"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "The name for the key pair."
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC id."
  type        = string
  default     = null
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
  default     = null
}

variable "tg_health_check" {
  type        = map(string)
  default     = {}
  description = "The default target group's health check configuration, will be merged over the default (see locals.tf)"
}

# variable "public_key" {
#   description = "The name for the key pair."
#   type        = string
#   default     = null
# }

variable "lb_listener_rule_action_type" {
  description = "value"
  type        = string
  default     = "forward"
}

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}

variable "http_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "ssh_port" {
  description = "The port for incoming SSH requests"
  type        = number
  default     = 22
}

variable "all_ports" {
  description = "The port for all outgoing requests"
  type        = number
  default     = 65535
}

variable "alb_listener_rule_priority" {
  description = "The port for all outgoing requests"
  type        = number
  default     = 100
}

variable "min_size" {
  description = "The minimum size of the autoscaling group"
  type        = number
  default     = 1
}

variable "routing_condition" {
  # description = <<-EOF 
  # This variable defines the paths
  # or domain names that will be routed to the servers. 
  # By default, we route all paths and domain names to the 
  # servers. To override this, you should pass in a 
  # list of maps, where each map has the keys field and 
  # values. The field can be one of: path-pattern, 
  # host-header, http-request-method, or source-ip. 
  # The values are an array of values for that field. 
  # See the Condition Blocks documentation for the syntax
  # to use: https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html.
  # EOF
  type = list(object({
    field  = string
    values = list(string)
  }))

  default = [
    {
      field  = "path-pattern"
      values = ["*"]
    },
  ]
}

variable "listener_rules" {
  type        = map(any)
  default     = {}
  description = "A map of listener rules for the LB: priority --> {target_group_arn:'', conditions:[]}. 'target_group_arn:null' means the built-in target group"
}

variable "health_check_protocol" {
  description = "The protocol to use to talk to the servers. Must be one of: HTTP, HTTPS."
  type        = string
  default     = "HTTP"
}

variable "health_check_interval" {
  description = "The approximate amount of time, in seconds, between health checks of each server. Minimum value 5 seconds, Maximum value 300 seconds."
  type        = number
  default     = 15
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a server. You can specify multiple comma-separated values (for example, \"200,202\") or a range of values (for example, \"200-299\")."
  type        = string
  default     = "200"
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response from a server means a failed health check. Must be between 2 and 60 seconds."
  type        = number
  default     = 3
}

variable "health_check_healthy_threshold" {
  description = "The number of times the health check must pass before a server is considered healthy."
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "The number of times the health check must fail before a server is considered unhealthy."
  type        = number
  default     = 2
}

variable "health_check_path" {
  description = "The path to use for health check requests."
  type        = string
}

variable "max_size" {
  description = "The maximum size of the autoscaling group"
  type        = number
  default     = 1
}

variable "alb_listener_port" {
  description = "The port for all outgoing requests"
  type        = number
  default     = 65535
}

variable "alb_protocol" {
  description = "The port for all outgoing requests"
  type        = string
  default     = "HTTP"
}

variable "lb_name" {
  description = "name of the load balencer for the ec2 instance"
  type        = string
  default     = null
}

variable "lb_target_group_name" {
  description = "name of the load balencer target group for the ec2 instance"
  type        = string
  default     = null
}
