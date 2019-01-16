output "vpc_security_group_ids" {
  value = "${aws_security_group.allow_within_vpc_traffic.id}"
  description = "A VPC security group that allows SSH access from within only the VPC"
}

output "vpc_default_id" {
  value = "${aws_default_vpc.default.id}"
  description = "The default VPC within the setup region"
}
