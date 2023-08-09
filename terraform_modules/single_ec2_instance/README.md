Provider tells Terraform to use AWS as provider and deploy 
into us-east-2 (Ohio) region, where you deploy the resources.

Provider - Name of a provider (eg aws)
Type - Type of resource to create in provider (eg instant)
Name - an identifier to refere to this resource
Config - One or more arguments that are specific to 
that resource


Step 1:

This is a Bash script that writes the text “Hello, World” 
into index.html and runs a tool called busybox 
(which is installed by default on Ubuntu) to fire up 
a web server on port 8080 to serve that file.

You pass a shell script to User Data by setting the 
user_data argument in your Terraform code as shown.

aws instance means virtual machine
virtual machine is a software (OS) and application 
which runs on existing hardware

VPC
uses user_data to install applications (web server)  
on the instance 
http web server
curl command reaches the http web server 
started by the user_dataProvider tells Terraform to use AWS as provider and deploy 
into us-east-2 (Ohio) region, where you deploy the resources.

Provider - Name of a provider (eg aws)
Type - Type of resource to create in provider (eg instant)
Name - an identifier to refere to this resource
Config - One or more arguments that are specific to 
that resource

Step 1:

This is a Bash script that writes the text “Hello, World” 
into index.html and runs a tool called busybox 
(which is installed by default on Ubuntu) to fire up 
a web server on port 8080 to serve that file.

You pass a shell script to User Data by setting the 
user_data argument in your Terraform code as shown.

aws instance means virtual machine
virtual machine is a software (OS) and application 
which runs on existing hardware

VPC
uses user_data to install applications (web server)  
on the instance 
http web server
curl command reaches the http web server 
started by the user_data

Two wasy to referece variable or resource. aws_lb_listener.http.arn





Curl: UDP/53: not in code
ALB DNS: not in code

Step 1:
ALB SG 
Step 2:
ALB
Step 3: 
ASG SG
Step 4:
ASG 

Output: It works: not in code