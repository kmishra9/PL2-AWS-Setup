# Local Variable Declarations
locals {
  cis_owner_id         = 679593333241
  ubuntu_home_dir_path = "/home/ubuntu"
  data_folder_path     = "/home/${var.data_folder_name}"
}

################################################################################
# AMI Setup

data "aws_ami" "cis_level_1_ami" {
  owners      = ["${local.cis_owner_id}"]
  most_recent = true

  filter {
    name      = "owner-id"
    values    = ["${local.cis_owner_id}"]
  }

  filter {
    name      = "name"
    values    = ["CIS Ubuntu Linux 16.04 LTS Benchmark*"]
  }

  name_regex  = "CIS Ubuntu Linux 16.04 LTS Benchmark-*(Level 1)*"
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
  vpc_security_group_ids               = ["${var.security_group_ids}"]
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
}

# EBS Volumes
resource "aws_ebs_volume" "data_storage" {
  availability_zone = "${var.region}${var.availability_zone}"
  encrypted         = "true"
  size              = "${var.EBS_volume_size}"
  tags              = {
    name = "${var.project_name}-data"
  }
}

resource "aws_volume_attachment" "data_storage_attachment" {
  count       = "${var.EBS_attach_volume}"
  device_name = "${var.EBS_device_name}"
  volume_id   = "${aws_ebs_volume.data_storage.id}"
  instance_id = "${aws_instance.EC2_analysis_instance.id}"
}

resource "null_resource" "delay" {
  triggers {
    new_volume   = "${aws_volume_attachment.data_storage_attachment.volume_id}"
    new_instance = "${aws_volume_attachment.data_storage_attachment.instance_id}"
  }

  provisioner "local-exec" {
    command = "sleep 30"
  }
}

# Trigger to begin installing things once EC2 is fully set up but wait for delay to complete
resource "null_resource" "EC2_setup" {
  triggers {
    new_volume   = "${aws_volume_attachment.data_storage_attachment.volume_id}"
    new_instance = "${aws_volume_attachment.data_storage_attachment.instance_id}"
  }

  depends_on = ["null_resource.delay"]

  ##############################################################################
  # Commands to run on creation of the EC2 resource

  # Transfer Provisioner Files
  provisioner "file" {
    source = "${path.module}/provisioner_scripts/"
    destination = "${local.ubuntu_home_dir_path}"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${aws_instance.EC2_analysis_instance.private_dns}"
      timeout     = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent       = "false"
    }
  }

  provisioner "remote-exec" {
    inline = [
      # Format attached EBS data volume so it can be mounted (if an existing filesystem does not already exist)
      "sudo mkfs -t xfs /dev/nvme1n1",
      # Configure Dpkg to ensure locking does not occur
      "sudo dpkg --configure -a",
      # Add Permissions to Provisioned Files
      "chmod 744 add_swap add_users install_cloudwatch_logs_agent install_programming_software install_updates mount_drives",
      # Reformat all provisioned scripts to be compatible with Unix instead of Windows
      "sed -i -e 's/\r$//' add_swap add_users install_cloudwatch_logs_agent install_programming_software install_updates mount_drives",
      # Add Swap
      "./add_swap",
      # Create Mountpoint for data folder
      "sudo mkdir ${local.data_folder_path}",
      "sudo chmod 777 ${local.data_folder_path}",
      # Mount the attached EBS drives
      "./mount_drives ${local.data_folder_path}",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${aws_instance.EC2_analysis_instance.private_dns}"
      timeout     = "30s"
      private_key = "${file(var.workspaces_private_key_path)}"
      agent       = "false"
    }
  }
}

# Python Script for staying secure: https://www.cisecurity.org/python-script-for-staying-secure-with-the-latest-cis-amis/

################################################################################
# Cloudwatch Idle Alarms

resource "aws_sns_topic" "idle_5_hours" {
  name = "idle_5_hours"
}

resource "aws_cloudwatch_metric_alarm" "idle_5_hours" {
  alarm_name          = "Idle-5-Hours"
  alarm_description   = "Alarm is triggered if max CPU usage does not exceed 10% in 5 hours"
  comparison_operator = "LessThanThreshold"
  threshold           = "10"
  evaluation_periods  = "60"
  datapoints_to_alarm = "60"
  period              = "300"
  statistic           = "Maximum"
  metric_name         = "CPUUtilization"
  treat_missing_data  = "notBreaching"

  namespace           = "AWS/EC2"
  dimensions          = {
    InstanceId = "${aws_instance.EC2_analysis_instance.id}"
  }

  alarm_actions = [
    "${aws_sns_topic.idle_5_hours.arn}"
  ]
}
