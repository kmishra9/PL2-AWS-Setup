variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. Kaiser_Flu). Be sure there is no whitespace (replace spaces with underscores: _ )"
}

variable "organization_name" {
  type = "string"
  description = "The name of the smallest-scale organization with ownership of this project (i.e. Colford_Lab or UCB). Be sure there is no whitespace (replace spaces with underscores: _ )"
}

variable "log_export" {
  type = "string"
  default = "true"
  description = "Only necessary at UC Berkeley, where logs will be exported for automated analysis"
}

variable "region" {
  type = "string"
  default = "us-west-2"
  description = "The region within which the S3 bucket should be spawned"
}

variable "stage" {
  type = "string"
  default = "prod"
  description = "The environment within which this AWS setup is being created: Dev, Stage, or Prod"
}
