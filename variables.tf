# Variable declarations for environment configuration

################################################################################
# Admin defined variables
################################################################################

variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. KaiserFlu). Be sure there is no whitespace (replace spaces with underscores: _ )"
}

variable "organization_name" {
  type = "string"
  description = "The name of the smallest-scale organization with ownership of this project (i.e. Colford_Lab or UCB). Be sure there is no whitespace (replace spaces with underscores: _ )"
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

variable "log_export" {
  type = "string"
  default = "true"
  description = "Only necessary at UC Berkeley, where logs will be exported for automated analysis"
}

################################################################################
# Build-defined variables
# Note: these have already been defined, there is no need to modify them unless
# you are an advanced user and know what changing these does
################################################################################

locals {
  region = "us-west-2"
  availability_zone = "a"
  stage = "prod"
}
