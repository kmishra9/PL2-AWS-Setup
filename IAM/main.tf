################################################################################
# Current AWS Account
data "aws_caller_identity" "current" {}

################################################################################
# IAM Password Policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
}

################################################################################
# Custom IAM Policy Documents
data "aws_iam_policy_document" "AllowUsersToManageTheirOwnVirtualMFADevice" {
  statement {
    sid = "AllowUsersToCreateEnableResyncDeleteTheirOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
  }

  statement {
    sid = "AllowUsersToDeactivateTheirOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:DeactivateMFADevice"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
  }

  statement {
    sid = "AllowUsersToListMFADevicesandUsersForConsole"
    effect = "Allow"
    actions = [
      "iam:GetAccountSummary",
      "iam:GetUser",
      "iam:GetLoginProfile",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ListUsers",
      "iam:ListAccountAliases",
      "iam:ListUserPolicies",
      "iam:ListGroupsForUser",
      "iam:ListUserTags",
      "iam:ListAccessKeys",
      "iam:ListSSHPublicKeys",
      "iam:ListServiceSpecificCredentials",
      "iam:ListSigningCertificates",
      "iam:ListPolicies"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "EC2ResearcherAccess" {
  statement {
    sid = "AllowUsersToTurnOnOffInstances"
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:StartInstances",
      "ec2:StopInstances",
      "ec2:RebootInstances",
      "cloudwatch:*"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "CloudWatchLogsPublish" {
  statement {
    sid = "AllowPublishToCloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "FlowLogsTrustCloudWatch" {
  statement {
    sid = "FlowLogsTrustCloudWatch"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "CloudWatchTrustEC2" {
  statement {
    sid = "CloudWatchTrustEC2"
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

################################################################################
# AWS Managed IAM Policies
data "aws_iam_policy" "AdministratorAccess" {
  arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_policy" "AmazonSQSFullAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

data "aws_iam_policy" "AmazonS3ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

################################################################################
# Custom IAM Policies
resource "aws_iam_policy" "AllowUsersToManageTheirOwnVirtualMFADevice" {
  name = "AllowUsersToManageTheirOwnVirtualMFADevice"
  policy = "${data.aws_iam_policy_document.AllowUsersToManageTheirOwnVirtualMFADevice.json}"
}

resource "aws_iam_policy" "EC2ResearcherAccess" {
  name = "EC2ResearcherAccess"
  policy = "${data.aws_iam_policy_document.EC2ResearcherAccess.json}"
}

resource "aws_iam_policy" "CloudWatchLogsPublish" {
  name = "CloudWatchLogsPublish"
  policy = "${data.aws_iam_policy_document.CloudWatchLogsPublish.json}"
}

################################################################################
# Custom IAM Roles
resource "aws_iam_role" "FlowLogsRole" {
  name = "FlowLogsRole"
  assume_role_policy = "${data.aws_iam_policy_document.FlowLogsTrustCloudWatch.json}"
}

resource "aws_iam_role" "CloudWatchLogsRole" {
  name = "CloudWatchLogsRole"
  assume_role_policy = "${data.aws_iam_policy_document.CloudWatchTrustEC2.json}"
}

resource "aws_iam_role_policy_attachment" "AttachCloudWatchLogsPublish_FlowLogsRole" {
  role       = "${aws_iam_role.FlowLogsRole.name}"
  policy_arn = "${aws_iam_policy.CloudWatchLogsPublish.arn}"
}

resource "aws_iam_role_policy_attachment" "AttachCloudWatchLogsPublish_CloudWatchLogsRole" {
  role       = "${aws_iam_role.CloudWatchLogsRole.name}"
  policy_arn = "${aws_iam_policy.CloudWatchLogsPublish.arn}"
}

################################################################################
# Custom Instance Profiles

resource "aws_iam_instance_profile" "CloudWatchLogsRole_instance_profile" {
  name = "${aws_iam_role.CloudWatchLogsRole.name}"
  role = "${aws_iam_role.CloudWatchLogsRole.name}"
}

################################################################################
# IAM Users
resource "aws_iam_user" "analysts" {
  count = "${var.num_researchers}"
  name = "Researcher_${count.index}"
}

resource "aws_iam_user" "administrators" {
  count = "${var.num_admins}"
  name = "Administrator_${count.index}"
}

resource "aws_iam_user" "log_analysts" {
  name = "Log_Analyst"
}

################################################################################
# IAM Groups
resource "aws_iam_group" "analysts" {
  name = "${var.project_name}_Analysts"
}

resource "aws_iam_group" "administrators" {
  name = "Administrators"
}

resource "aws_iam_group" "log_analysts" {
  name = "${var.project_name}_Log_Analysts"
}

################################################################################
# Adding IAM policies to groups
resource "aws_iam_group_policy_attachment" "add_analysts_AllowUsersToManageTheirOwnVirtualMFADevice" {
  group      = "${aws_iam_group.analysts.name}"
  policy_arn = "${aws_iam_policy.AllowUsersToManageTheirOwnVirtualMFADevice.arn}"
}

resource "aws_iam_group_policy_attachment" "add_analysts_EC2ResearcherAccess" {
  group      = "${aws_iam_group.analysts.name}"
  policy_arn = "${aws_iam_policy.EC2ResearcherAccess.arn}"
}

resource "aws_iam_group_policy_attachment" "add_administrators_AdministratorAccess" {
  group      = "${aws_iam_group.administrators.name}"
  policy_arn = "${data.aws_iam_policy.AdministratorAccess.arn}"
}

resource "aws_iam_group_policy_attachment" "add_log_analysts_AmazonSQSFullAccess" {
  group      = "${aws_iam_group.log_analysts.name}"
  policy_arn = "${data.aws_iam_policy.AmazonSQSFullAccess.arn}"
}

resource "aws_iam_group_policy_attachment" "add_log_analysts_AmazonS3ReadOnlyAccess" {
  group      = "${aws_iam_group.log_analysts.name}"
  policy_arn = "${data.aws_iam_policy.AmazonS3ReadOnlyAccess.arn}"
}

################################################################################
# Adding IAM users to groups
resource "aws_iam_group_membership" "add_analysts" {
  name  = "add_analysts"

  users = ["${aws_iam_user.analysts.*.name}"]
  group = "${aws_iam_group.analysts.name}"
}

resource "aws_iam_group_membership" "add_administrators" {
  name  = "add_administrators"

  users = ["${aws_iam_user.administrators.*.name}"]
  group = "${aws_iam_group.administrators.name}"
}

resource "aws_iam_group_membership" "add_log_analysts" {
  name  = "add_log_analysts"

  users = ["${aws_iam_user.log_analysts.*.name}"]
  group = "${aws_iam_group.log_analysts.name}"
}
