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
  description = "The type of instance to create - see the EC2 Instance Pricing guide: https://aws.amazon.com/ec2/pricing/on-demand/"
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

variable "EBS_device_name" {
  type = "string"
  default = "/dev/sdf"
  description = "The device name of the EBS volume to expose to the instance - see documentation on device naming on Linux instances: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/device_naming.html"
}

variable "EBS_attach_volume" {
  type = "string"
  default = "1"
  description = "Whether or not to have Terraform attach the EBS data volume directly to the EC2 instance. Can be set to '0' in case the instance type specified does not support EBS devices at the default 'EBS_device_name'"
}

variable "data_folder_name" {
  type = "string"
  default = "sensitive_data"
  description = "The name of the folder the data will be stored in (on the EBS volume)"
}

variable "cloudwatch_logs_role_name" {
  type        = "string"
  description = "The name of a role with appropriate permissions to publish CloudWatch Logs from the agent and a trust relationship with EC2."
}

variable "workspaces_public_key_path" {
  type = "string"
  default = "~/.ssh/id_rsa.pub"
  description = "The public key path (relative or absolute) of the AWS Workspace from which this setup is being administered, to be imported as an 'EC2 KeyPair'"
}

variable "workspaces_private_key_path" {
  type = "string"
  default = "~/.ssh/id_rsa"
  description = "The private key path (relative or absolute) of the AWS Workspace from which this setup is being administered, used to connect via SSH to the instance"
}
