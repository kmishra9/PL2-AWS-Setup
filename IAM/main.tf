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

# Custom IAM Policies
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

data "aws_iam_policy_document" "CloudWatchLogsRole" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_policy" "AllowUsersToManageTheirOwnVirtualMFADevice" {
  
}
