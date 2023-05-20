# Tells Terraform to use AWS as provider and deploy 
# into us-east-2 (Ohio) region.

provider "aws" {
  region = "us-east-1"
}

# The general syntax for creating a resource 
# in Terraform is as follows:

# resource "<PROVIDER>_<TYPE>" "<NAME>" {
#  [CONFIG …]
# }

# resource "aws_instance" "example" {
#   ami           =  "ami-0889a44b331db0194" 
#   instance_type =  "t2.micro"
#   tags = {
#     Name = "terraform-example"
#   }
# }

# Provider - Name of a provider (eg aws)
# Type - Type of resource to create in provider (eg instant)
# Name - an identifier to refere to this resource
# Config - One or more arguments that are specific to that resource

# Step 1:

# This is a Bash script that writes the text “Hello, World” 
# into index.html and runs a tool called busybox 
# (which is installed by default on Ubuntu) to fire up 
# a web server on port 8080 to serve that file.

#!/bin/bash
# echo "Hello, World" > index.html
# nohup busybox httpd -f -p 8080 &

# Step 2: 

# You pass a shell script to User Data by setting the 
# user_data argument in your Terraform code as follows:


# resource "aws_instance" "example" {
#   ami                    = "ami-0889a44b331db0194"
#   instance_type          = "t2.micro"
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               nohup busybox httpd -f -p 8080 &
#               EOF

#   user_data_replace_on_change = true

#   tags = {
#     Name = "terraform-example"
#   }
# }


# Step 3: 

# By default, AWS does not allow any incoming or outgoing 
# traffic from an EC2 Instance. To allow the EC2 
# Instance to receive traffic on port 8080, you need to 
# create a security group:

# To access the ID of the security group resource,
# you are going to need to use a resource attribute reference,
# <provider>_<Type>.<Name>.<Attribute>


resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
     # This IP address range 0.0.0.0/0 includes all. 
    # This allows incoming requests on port 8080 from any IP.
    cidr_blocks = ["0.0.0.0/0"]
   }
  }
# This code creates a new resource called aws_security_group
# and specifies that this group allows incoming TCP requests
# on port 8080 from the CIDR block.

resource "aws_instance" "example" {
  ami                    = "ami-0889a44b331db0194"
  instance_type          = "t2.micro"
  # List of security group IDs to associate with. 
  vpc_security_group_ids = [aws_security_group.instance.id]
  # User data to provide when launching the instance. 
  # Updates to this field will trigger a start/stop of 
  # EC2 instance by default. 
# Line 103 used to create an index.html file and with 
# Hello, World in it. 
# Line 104  used to run the script even after you log off. 
# It continues to run until it is finished. 
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  # used to terminate any previous pushes to aws server. 
  user_data_replace_on_change = true
  # creates a name for aws server
  tags = {
    Name = "terraform-example"
  }
}









