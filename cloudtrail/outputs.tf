output "logs_bucket_id" {
  value       = "${module.cloudtrail_s3_bucket.bucket_id}"
  description = "The id of the bucket within which logs from cloudtrail are being stored"
}

output "logs_topic_id" {
  value       = "${aws_sns_topic.project_logs.id}"
  description = "The id of the topic where events are published to when logs are created in the logs_bucket"
}
