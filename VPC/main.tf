################################################################################
# Security Group for VPC Firewall
resource "aws_security_group" "allow_within_vpc_traffic" {
  name        = "allow_within_vpc_traffic"
  description = "Allows all inbound traffic from within the VPC + all outbound traffic. Managed by Terraform."
  vpc_id      = "${aws_default_vpc.default.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################################################################################
# Default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "${var.project_name}_VPC"
  }
}

################################################################################
# VPC Flow Logs -> Cloudwatch
resource "aws_flow_log" "VPC_flow_logs" {
  traffic_type         = "ALL"
  iam_role_arn         = "${var.flow_logs_role.arn}"
  log_destination_type = "cloud-watch-logs"
  log_destination      = "${aws_cloudwatch_log_group.cloudwatch_VPC_flow_logs.arn}"
  vpc_id               = "${aws_default_vpc.default.id}"
}

resource "aws_cloudwatch_log_group" "cloudwatch_VPC_flow_logs" {
  name = "${var.project_name}_cloudwatch_VPC_flow_logs"
}
