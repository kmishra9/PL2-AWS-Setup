# Variable declarations for environment configuration

################################################################################
# Admin defined variables
################################################################################

variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. Kaiser-Flu). Be sure there is no whitespace (replace spaces with hyphens '-', only alphanumeric characters and hyphens are allowed)"
}

variable "organization_name" {
  type = "string"
  description = "The name of the smallest-scale organization with ownership of this project (i.e. Colford-Lab or UCB). Be sure there is no whitespace (replace spaces with hyphens '-', only alphanumeric characters and hyphens are allowed)"
}

variable "access_key" {
  type = "string"
  description = "The access key of the Terraform IAM user that was setup with administrator access"
}

variable "secret_key" {
  type = "string"
  description = "The secret key of the Terraform IAM user that was setup with administrator access"
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

variable "num_researchers" {
  type = "string"
  description = "The integer number of researchers who will be participating in this project - creates the given number of Researcher IAM accounts"
}

variable "num_admins" {
  type = "string"
  description = "The integer number of administrators who will be participating in this project - creates the given number of Administrator IAM accounts"
}

variable "instance_type" {
  type = "string"
  description = "The type of instance to create - see the EC2 Instance Pricing guide: https://aws.amazon.com/ec2/pricing/on-demand/. Example: 't2.micro'"
}

variable "root_volume_size" {
  type = "string"
  description = "The integer volume size (in GB) of the root EC2 analysis instance. This volume should not contain sensitive data. Roughly 50 GB will be reserved by the system."
}

variable "EBS_volume_size" {
  type = "string"
  description = "The volume size (in GB) of the EBS data storage volume attached to the EC2 analysis instance. Should be the only volume containing sensitive data."
}

variable "data_folder_name" {
  type = "string"
  default = "sensitive_data"
  description = "The name of the folder the data will be stored in (on the EBS volume). Be sure there is no whitespace (replace spaces with underscores '_', only lowercase alphanumeric characters and hyphens are allowed)"
}

################################################################################
# Build-defined variables
# Note: these have already been defined, there is no need to modify them (in
# this file) unless you are an advanced user and know what changing these does
################################################################################

locals {
  region = "us-west-2"
  availability_zone = "a"
  stage = "prod"
  EBS_device_name = "/dev/sdf"
  EBS_attach_volume = "1"
}
