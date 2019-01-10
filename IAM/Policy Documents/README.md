# Custom Policy Documents

There are 3 custom policies included within this module. Each is implemented as a Terraform `aws_iam_policy_document` data source and used to create an `aws_iam_policy` resource. They are documented below:

- **AllowUsersToManageTheirOwnVirtualMFADevice** —- based off an [example policy outlined in AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_delegate-permissions_examples.html#creds-policies-mfa-console) that allows users to manage their own MFA device.
- **EC2ResearcherAccess** -- based off of an [example policy outlined in an AWS community forum](https://forums.aws.amazon.com/thread.jspa?threadID=149941) that allows users to start/stop/reboot existing instances and see but not modify other things in the EC2 Management Console
- **CloudWatchLogsRole** -- based off [AWS documentation for an example policy](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/QuickStartEC2Instance.html) responsible for installing and configuring a role for CloudWatch Logs
