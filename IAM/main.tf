# Current AWS Account
data "aws_caller_identity" "current" {}

# IAM Password Policy
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 12
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
}

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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}",                # TODO: these arns need to be interpolated
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
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:mfa/$${aws:username}",                # TODO: these arns need to be interpolated
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"
    ]
    condition {
      test = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values = ["true"]
    }
  }

  statement {
    sid = "AllowUsersToListMFADevicesandUsersForConsole"
    effect = "Allow"
    actions = [
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ListUsers"
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
  policy = "${data.aws_iam_policy_document.CloudWatchLogsRole.json}"
}

# Custom IAM Roles
resource "aws_iam_role" "FlowLogsRole" {
  name = "FlowLogsRole"
  assume_role_policy = "${data.aws_iam_policy_document.FlowLogsTrustCloudWatch.json}"
}

resource "aws_iam_role_policy_attachment" "AttachCloudWatchLogsPublish" {
  role       = "${aws_iam_role.FlowLogsRole.name}"
  policy_arn = "${aws_iam_policy.CloudWatchLogsPublish.arn}"
}

# IAM Groups
resource "aws_iam_group" "analysts" {
  name = "${var.project_name}_Analysts"
}

resource "aws_iam_group" "administrators" {
  name = "Administrators"
}

resource "aws_iam_group" "log_analysts" {
  count = "${var.log_export}"
  name = "${var.project_name}_Log_Analysts"
}

# TODO: Adding policies to groups

# IAM Users
resource "aws_iam_user" "analysts" {
  count = "${var.num_researchers}"
  name = "Researcher_${count.index}"
}

resource "aws_iam_user" "administrators" {
  count = "${var.num_admins}"
  name = "Administrator_${count.index}"
}
