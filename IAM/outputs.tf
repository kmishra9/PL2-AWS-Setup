output "FlowLogsRole" {
  value       = "${aws_iam_role.FlowLogsRole}"
  description = "A custom-written IAM role to be used in setting up VPC Flow Logs"
}

output "CloudWatchLogsRole" {
  value       = "${aws_iam_role.CloudWatchLogsRole}"
  description = "A custom-written IAM role to be used by EC2 instances and the CloudWatch Log Agent"
}
