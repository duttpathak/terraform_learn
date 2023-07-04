# Tells Terraform to use AWS as provider and deploy 
# into us-east-2 (Ohio) region.

# where you deploy the resources

provider "aws" {
  region = "us-east-1"
}

# # Provider - Name of a provider (eg aws)
# # Type - Type of resource to create in provider (eg instant)
# # Name - an identifier to refere to this resource
# # Config - One or more arguments that are specific to that resource

# # Step 1:

# # This is a Bash script that writes the text “Hello, World” 
# # into index.html and runs a tool called busybox 
# # (which is installed by default on Ubuntu) to fire up 
# # a web server on port 8080 to serve that file.

# #!/bin/bash
# # echo "Hello, World" > index.html
# # nohup busybox httpd -f -p 8080 &

# # Step 2: 

# # You pass a shell script to User Data by setting the 
# # user_data argument in your Terraform code as follows:

# # aws instance means virtual machine
# # virtual machine is a software (OS) and application 
# # which runs on existing hardware

resource "aws_instance" "example" {
  # Running Amazon Linux 2023 AMI 
  # 2023.0.20230503.0 x86_64 HVM kernel-6.1
  ami           = "ami-0889a44b331db0194"
  instance_type = "t2.micro"
  # key_name               = aws_key_pair.terraform.key_name
  vpc_security_group_ids = [aws_security_group.instance.id]
  # uses user_data to install applications (web server)  
  # on the instance 
  # http web server
  # curl command reaches the http web server 
  # started by the user_data

  user_data = <<-EOF
        #!/bin/bash
        set -ex

        dnf update -y
        # install the http server 
        dnf install -y httpd
        # starts the http server
        systemctl start httpd
        EOF

  # user_data_replace_on_change = true

  tags = {
    Name = "terraform-example"
  }
}

# resource "aws_security_group" "instance" {
#   name = "terraform-example-instance"
#   ingress {
#     # port 80 on the instance. 
#     # Everyone uses port 80
#     from_port = var.server_port
#     to_port   = var.server_port
#     protocol  = "tcp"
#     # This IP address range 0.0.0.0/0 includes all. 
#     # This allows incoming requests on port 8080 from any IP.
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # ingress is for incoming requests.
#   ingress {
#     from_port = var.server_port_in
#     to_port   = var.server_port_in
#     protocol  = "tcp"
#     # This IP address range 0.0.0.0/0 includes all. 
#     # This allows incoming requests on port 8080 from any IP.
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   # egress is for outgoing requests.
#   # outgoing means from the instance 
#   # connect to something
#   egress {
#     # to do: what port for full outbound excess 
#     from_port = 0
#     to_port   = var.server_port_out
#     protocol  = "tcp"
#     # This IP address range 0.0.0.0/0 includes all. 
#     # This allows incoming requests on port 8080 from any IP.
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }
# This code creates a new resource called aws_security_group
# and specifies that this group allows incoming TCP requests
# on port 8080 from the CIDR block.
# CIDR blocks are a concise way to specify IP address ranges.
# Step 3: 

# By default, AWS does not allow any incoming or outgoing 
# traffic from an EC2 Instance. To allow the EC2 
# Instance to receive traffic on port 8080, you need to 
# create a security group:

# To access the ID of the security group resource,
# you are going to need to use a resource attribute reference,
# <provider>_<Type>.<Name>.<Attribute>





# resource "aws_key_pair" "terraform" {
#   key_name   = "terraform"
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBGrHCC95QsUPZozICYflAVpTHe0gcBUDklM3CYmYqUvwHXNSRoZEQWv+HMMNHAekDg3UKG27l+mYCqHiOOHMCmNjPBa6JvwBHTlBI0MHnZao2IZbRph72+3BQ3tIErXQeHhcgjbqQYMsrJRNqof4kUzNztQc6eKWyrMPWtgN7KmhU4efA03tsEwM2cl89YKHxAh5BkKIgbwPXwWyRCSl8N/cBgDNXA3rtHw/gAzunBW2GpB4CQekng9ddShOzn5vgs4ODoDOvyHSl1boj2cMu3/R95c8VgsralyobQ6s4NN7WhjtJmfumbz5kAfD4zAu3UFm5JJBRhjv7hLXIkrq7LKGpgoGkPEGKV01pK61sSYEngesZ3knjQXWanmJqbLdHhH+pzZG2zmGeI5BzOsHuSPdA9+pPXO/glZg5zK8aiSAWjmNGcPS1h1Tfbz4zk8fSGYL7HB0vTVOt4GPkwv9MEUr/hZUsJ+uk1G4t6lrglgrqCY3UvT0JXh0etlPWrtREtYXNYLOoYM44IcJKWGeLSjyIpe0IVyNldvdfWiJe5fnabmCIJhOaep2xClMuCqhkpBIVpzLFcEEqupGoJSH0G5i8xlQ/V9C5mL4xuF3IN1ah+gHNqb4PXGxXpSCxfE3jmgBG0GcBymQPONnjPjOiMwRvx6qCbowhQ+LdyxVfmQ== tarpanpathak720@gmail.com"
# }

# https instead of busybox

# the region where the bucket resides.

terraform {
  backend "s3" {
    bucket = "tf-state-nonprod"
    key    = "github.com/duttpathak/terraform_learn/main"
    region = "us-west-2"
  }
}

output "public_ip" {
  value       = "curl http://${aws_instance.example.public_ip}"
  description = "The public IP address of the web server"
}
