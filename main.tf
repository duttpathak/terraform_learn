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

resource "aws_instance" "example" {
  ami           =  "ami-0889a44b331db0194" 
  instance_type =  "t2.micro"
  tags = {
    Name = "terraform-example"
  }
}

# Provider - Name of a provider (eg aws)
# Type - Type of resource to create in provider (eg instant)
# Name - an identifier to refere to this resource
# Config - One or more arguments that are specific to that resource