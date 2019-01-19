variable "project_name" {
  type = "string"
  description = "The name of the project utilizing this setup (i.e. Kaiser_Flu). Be sure there is no whitespace (replace spaces with underscores: _ )"
}

variable "flow_logs_role_name" {
  description = "The name of a custom-written IAM role to be used in setting up VPC Flow Logs"
}
