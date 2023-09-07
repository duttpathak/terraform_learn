provider "aws" {
  region = var.region
}

# resource "aws_key_pair" "terraform" {
#   key_name   = var.key_name
#   public_key = var.public_key
# }

resource "aws_instance" "example" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.instance.id]
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  tags                        = var.tags
}

# port 80 on the instance. 
# Everyone uses port 80
# This IP address range 0.0.0.0/0 includes all. 
# This allows incoming requests on port 8080 from any IP.
# Allows incoming and or outgoing access.

resource "aws_security_group" "instance" {
  name = var.security_group_name
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # uncomment if need to access the instance.
  # ingress is for incoming requests.
  # This IP address range 0.0.0.0/0 includes all. 
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # egress is for outgoing requests.
  # outgoing means from the instance 
  # connect to something
  # This IP address range 0.0.0.0/0 includes all. 
  # This allows incoming requests on port 8080 from any IP.
  # to do: what port for full outbound excess 
  egress {
    from_port   = 0
    to_port     = var.all_ports
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# module is list of .tf files under the modules directory







