################################################################################
# AMI Setup
locals {
  cis_owner_id = 679593333241
}

data "aws_ami" "cis_level_1_ami" {
  most_recent = true

  filter {
    name = "owner-id"
    values = ["${local.cis_owner_id}"]
  }

  filter {
    name = "name"
    values = ["CIS Ubuntu Linux 16.04 LTS Benchmark*"]
  }

  name_regex = "CIS Ubuntu Linux 16.04 LTS Benchmark-*(Level 1)*"
}

################################################################################
# EC2 Instance Setup

resource "aws_instance" "EC2_analysis_instance" {
  ami                                  = "${data.aws_ami.cis_level_1_ami.id}"
  availability_zone                    = "${var.region}${var.availability_zone}"
  tenancy                              = "default"
  disable_api_termination              = "true"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "${var.instance_type}"
  monitoring                           = "true"
  vpc_security_group_ids               = ["${var.security_group_ids}"]
  iam_instance_profile                 = "${var.cloudwatch_logs_role_name}"

  tags = {
    Name = "${var.project_name}-EC2-analysis-instance"
  }

  # Root Storage
  root_block_device = {
    volume_type           = "standard"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "false"
  }

  ##############################################################################
  # Commands to run on creation of the EC2 resource

  provisioner "file" {
    source = "./provisioner_scripts/"
    destination = "/home/ubuntu"
  }

  # Add Swap
  provisioner "local-exec"{
    command = ""
    working_dir = "~/"
  }

  # Mount Drives
  provisioner "local-exec" {
    command = ""
    working_dir = "~/"
  }
}

# EBS Volumes
resource "aws_ebs_volume" "data_storage" {
  availability_zone = "${var.region}${var.availability_zone}"
  encrypted = "true"
  size = "${var.EBS_volume_size}"
  tags = {
    name = "${var.project_name}-data"
  }
}

resource "aws_volume_attachment" "data_storage_attachment" {
  count       = "${var.EBS_attach_volume}"
  device_name = "${var.EBS_device_name}"
  volume_id   = "${aws_ebs_volume.data_storage.id}"
  instance_id = "${aws_instance.EC2_analysis_instance.id}"
}


# Python Script for staying secure: https://www.cisecurity.org/python-script-for-staying-secure-with-the-latest-cis-amis/
