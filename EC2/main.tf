################################################################################
# AMI Setup
locals {
  cis_owner_id = 679593333241
}

data "aws_ami" "cis_level_1_ami" {
  owners       = ["${local.cis_owner_id}"]
  name_regex   = "CIS Ubuntu Linux 16.04 LTS Benchmark Level 1"
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
  vpc_security_group_ids               = "${var.security_group_ids}"
  iam_instance_profile                 = "${var.cloudwatch_logs_role_name}"

  tags = {
    Name = "${var.project_name}_EC2_analysis_instance"
  }

  ##############################################################################
  # EBS volumes attached to the EC2 resource
  root_block_device = {
    volume_type           = "standard"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "false"
  }

  ebs_block_device = {
    device_name           = "${var.project_name}_data"
    volume_type           = "standard"
    volume_size           = "${var.EBS_volume_size}"
    delete_on_termination = "false"
    encrypted             = "true"
  }

  ##############################################################################
  # Commands to run on creation of the EC2 resource

  # TODO: Need to determine whether it's possible to connect to a cis ami through terraform like this (or how to at all)

  # Add Swap
  provisioner "local-exec"{
    command = ""
    working_dir = "~/"
  }

  # Mount Drives
  provisioner "local-exec" "mount_drives" {
    command = ""
    working_dir = "~/"
  }

}


# Python Script for staying secure: https://www.cisecurity.org/python-script-for-staying-secure-with-the-latest-cis-amis/
