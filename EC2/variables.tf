variable "project_name" {
  type        = "string"
  description = "The name of the project utilizing this setup (i.e. Kaiser_Flu). Be sure there is no whitespace (replace spaces with underscores: _ )."
}

variable "region" {
  type        = "string"
  default     = "us-west-2"
}

variable "availability_zone" {
  type        = "string"
  default     = "a"
}

variable "instance_type" {
  type        = "string"
  default     = "t2.micro"
  description = "The type of instance to create - see the EC2 Instance Pricing guide: https://aws.amazon.com/ec2/pricing/on-demand/ - Defaults to free-tier t2.micro."
}

variable "security_group_ids" {
  type        = "list"
  description = "A list of security group ids to apply to the EC2 instance."
}

variable "root_volume_size" {
  type        = "string"
  default     = "100"
  description = "The volume size (in GB) of the root EC2 analysis instance. Should not contain sensitive data. Roughly 50 GB will be consumed by the system."
}

variable "EBS_volume_size" {
  type        = "string"
  default     = "100"
  description = "The volume size (in GB) of the EBS data storage volume attached to the EC2 analysis instance. Should be the only volume containing sensitive data."
}

variable "cloudwatch_logs_role_name" {
  type        = "string"
  description = "The name of a role with appropriate permissions to publish CloudWatch Logs from the agent and a trust relationship with EC2."
}
