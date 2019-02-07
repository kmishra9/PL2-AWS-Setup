# Local Variable Declarations
locals {
  cis_owner_id = 679593333241
  ubuntu_home_dir_path = "/home/ubuntu"
  data_folder_path = "/home/${var.data_folder_name}"
}

################################################################################
# AMI Setup

data "aws_ami" "cis_level_1_ami" {
  most_recent = true

  filter {
    name = "owner-id"
    values = ["${local.cis_owner_id}"]
  }

  filter {
    name = "name"
    values = ["CIS Ubuntu Linux 18.04 LTS Benchmark*"]
  }

  name_regex = "CIS Ubuntu Linux 18.04 LTS Benchmark-*(Level 1)*"
}

################################################################################
# EC2 Instance Setup

resource "aws_key_pair" "workspaces_keypair" {
  key_name   = "Workspaces_Key"
  public_key = "${file(var.workspaces_public_key_path)}"
}

resource "aws_instance" "EC2_analysis_instance" {
  ami                                  = "${data.aws_ami.cis_level_1_ami.id}"
  availability_zone                    = "${var.region}${var.availability_zone}"
  tenancy                              = "default"
  # disable_api_termination              = "true"
  disable_api_termination              = "false"
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "${var.instance_type}"
  key_name                             = "${aws_key_pair.workspaces_keypair.key_name}"
  monitoring                           = "true"
  #vpc_security_group_ids               = ["${var.security_group_ids}"]
  iam_instance_profile                 = "${var.cloudwatch_logs_role_name}"

  tags = {
    Name = "${var.project_name}-EC2-analysis-instance"
  }

  # Root Storage
  root_block_device = {
    volume_type           = "standard"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "true"
  }

  ##############################################################################
  # Commands to run on creation of the EC2 resource

  # Transfer Provisioner Files
  provisioner "file" {
    source = "${path.module}/provisioner_scripts/"
    destination = "${local.ubuntu_home_dir_path}"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.EC2_analysis_instance.public_dns}"
      timeout  = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent    = "false"
    }
  }

  # Add Permissions to Provisioned Files
  provisioner "local-exec" {
    command = "chmod 744 add_swap add_users install_programming_software install_updates mount_drives"
    working_dir = "${local.ubuntu_home_dir_path}"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.EC2_analysis_instance.public_dns}"
      timeout  = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent    = "false"
    }
  }

  # Add Swap
  provisioner "local-exec" {
    command = "./add_swap"
    working_dir = "${local.ubuntu_home_dir_path}"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.EC2_analysis_instance.public_dns}"
      timeout  = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent    = "false"
    }
  }

  # Mount Drives
  provisioner "local-exec" {
    command = "./mount_drives ${local.data_folder_path}"
    working_dir = "${local.ubuntu_home_dir_path}"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.EC2_analysis_instance.public_dns}"
      timeout  = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent    = "false"
    }
  }


  # Add Researcher Accounts
  provisioner "local-exec" {
    command = "./add_users ${local.data_folder_path} ${var.num_researchers}"
    working_dir = "${local.ubuntu_home_dir_path}"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.EC2_analysis_instance.public_dns}"
      timeout  = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent    = "false"
    }
  }

  # Install R, RStudio, Python3, and JupyterHub
  provisioner "local-exec" {
    command = "./add_users ${local.data_folder_path} ${var.num_researchers}"
    working_dir = "${local.ubuntu_home_dir_path}"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.EC2_analysis_instance.public_dns}"
      timeout  = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent    = "false"
    }
  }

  # Install CloudWatch Agent
  provisioner "local-exec" {
    command = ""
    working_dir = "~/"

    connection {
      type     = "ssh"
      user     = "ubuntu"
      host     = "${aws_instance.EC2_analysis_instance.public_dns}"
      timeout  = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent    = "false"
    }
  }


  # Install Updates & Reboot
  provisioner "local-exec" {
    command = "./install_updates"
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
