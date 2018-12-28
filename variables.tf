# Variable definitions for environment configuration


variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. KaiserFlu)"
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
