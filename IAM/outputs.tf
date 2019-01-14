output "FlowLogsRole" {
  value       = "${aws_iam_role.FlowLogsRole}"
  description = "A custom-written IAM role to be used in setting up VPC Flow Logs"
}
