# Variable definitions for environment configuration

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
