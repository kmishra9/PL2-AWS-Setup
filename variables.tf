# Variable declarations for environment configuration

################################################################################
# Admin defined variables
################################################################################

variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. KaiserFlu)"
}

variable "access_key" {
  type = "string"
  description = "The access key of the Terraform IAM user that was setup with administrator access"
}

variable "secret_key" {
  type = "string"
  description = "The secret key of the Terraform IAM user that was setup with administrator access"
}

variable "num_researchers" {
  type = "string"
  default = "1"
  description = "The number of researchers who will be participating in this project - creates the given number of Researcher IAM accounts"
}

variable "num_admins" {
  type = "string"
  default = "1"
  description = "The number of administrators who will be participating in this project - creates the given number of Administrator IAM accounts"
}

################################################################################
# Build-defined variables
# Note: these have already been defined, there is no need to modify them unless
# you are an advanced user and know what changing these does
################################################################################

variable "region" {
  type = "string"
  default = "us-west-2"
  description = "The region within which the AWS Setup will reside"
}

variable "availability_zone" {
  type = "string"
  default = "a"
  description = "The availability zone within the region within which the AWS Setup will reside"
}
