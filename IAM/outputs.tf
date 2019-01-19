output "FlowLogsRole_name" {
  value       = "${aws_iam_role.FlowLogsRole.name}"
  description = "The name of a custom-written IAM role to be used in setting up VPC Flow Logs"
}

output "CloudWatchLogsRole_name" {
  value       = "${aws_iam_role.CloudWatchLogsRole.name}"
  description = "The name of a custom-written IAM role to be used by EC2 instances and the CloudWatch Log Agent"
}
