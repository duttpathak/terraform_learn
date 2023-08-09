variable "ami" {
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
  argument. Updates to this field will trigger a stop/start of the EC2 instance 
  by default. If the user_data_replace_on_change is set then 
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

variable "vpc_id" {
  type        = string
  description = "VPC ID."
  sensitive   = true
}

variable "cb_destroy" {
  description = "will create new instance before destorying"
  type        = bool
  default     = true
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
  default     = null
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

variable "public_key" {
  description = "The name for the key pair."
  type        = string
  default     = null
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
