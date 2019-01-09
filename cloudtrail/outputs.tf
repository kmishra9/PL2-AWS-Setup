output "logs_bucket" {
  value       = "${module.cloudtrail_s3_bucket}"
  description = "The bucket within which logs from cloudtrail are being stored"
}

output "logs_topic" {
  value       = "${aws_sns_topic.project_logs}"
  description = "The topic where events are published to when logs are created in the logs_bucket"
}
