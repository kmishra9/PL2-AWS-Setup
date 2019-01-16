variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. Kaiser_Flu). Be sure there is no whitespace (replace spaces with underscores: _ )"
}

variable "region" {
  type = "string"
  default = "us-west-2"
}

variable "availability_zone" {
  type = "string"
  default = "a"
}

variable "instance_type" {
  type = "string"
  default = "t2.micro"
  description = "The type of instance to create - see the EC2 Instance Pricing guide: https://aws.amazon.com/ec2/pricing/on-demand/ - Defaults to free-tier t2.micro"
}

variable "security_group_ids" {
  type = "list"
  description = "A list of security group ids to apply to the EC2 instance"
}
