Why is terraform state required?

How does terraform know which ec2 instance/any changes/resources to create/add in aws. Terraform state file acts as a data center to store changes/addition to your terraform infrastructure. Terraform state will catch the infrastructure you are running currently. 








Every time you run Terraform, it records information about what infrastructure it created in a Terraform state file. By default, when you run Terraform in the folder /foo/bar, Terraform creates the file 
/foo/bar/terraform.tfstate.


This input: 

resource "aws_instance" "example" {
  ami           = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
}


Will output this after running terraform apply, in a JSON format that records a mapping from the Terraform resources in your configuration files to the representation of those resources in the real world. 

{
  "version": 4,
  "terraform_version": "1.2.3",
  "serial": 1,
  "lineage": "86545604-7463-4aa5-e9e8-a2a221de98d2",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_instance",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/...\"]",
      "instances": [
        {
          "schema_version": 1,
          "attributes": {
            "ami": "ami-0fb653ca2d3203ac1",
            "availability_zone": "us-east-2b",
            "id": "i-0bc4bbe5b84387543",
            "instance_state": "running",
            "instance_type": "t2.micro",
            "(...)": "(truncated)"
          }
        }
      ]
    }
  ]
}


Using this JSON format, Terraform knows that a resource with type aws_instance and name example corresponds to an EC2 Instance in your AWS account with ID i-0bc4bbe5b84387543



If using terraform in a team on a real product, these are the problems:
Shared storage for state files.
Locking state files.
Isolating state files.