variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. Kaiser_Flu). Be sure there is no whitespace (replace spaces with underscores: _ )"
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
