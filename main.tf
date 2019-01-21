/* TODO:

- Security Token Service Regions (Deactivate pretty much everything except for US West (Oregon))
- Adding provisioners for iptable setup, ssh tunnel creation, users being added (docs: https://www.terraform.io/docs/provisioners/index.html)
  - The file provisioner in particular would be a nice way to port scripts from the github repo to the instance
  - local-exec will be useful once scripts have been deposited in the appropriate -- you can interpolate resource variables (such as VPC ips, which should be useful for iptables setup)

- What is AWS security hub and how should I use it?
- Do I still need an elastic IP if I'm connecting within the VPC?
*/

################################################################################
# Initial Account Setup
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${local.region}"
}

################################################################################
# Configuring CloudTrail

module "cloudtrail" {
  source            = "./cloudtrail"
  project_name      = "${var.project_name}"
  organization_name = "${var.organization_name}"
  region            = "${local.region}"
  stage             = "${local.stage}"
}

################################################################################
# Configuring IAM users, roles, groups, and privileges

module "IAM" {
  source          = "./IAM"
  project_name    = "${var.project_name}"
  num_researchers = "${var.num_researchers}"
  num_admins      = "${var.num_admins}"
}

################################################################################
# Configuring network, firewalls, and network logs

module "VPC" {
  source         = "./VPC"
  project_name   = "${var.project_name}"
  flow_logs_role_name = "${module.IAM.FlowLogsRole_name}"
}

################################################################################
# Configuring the analysis instance

module "EC2" {
  source             = "./EC2"
  project_name       = "${var.project_name}"
  region             = "${local.region}"
  availability_zone  = "${local.availability_zone}"
  instance_type      = "${var.instance_type}"
  security_group_ids = ["${module.VPC.vpc_security_group_ids}"]
  root_volume_size   = "${var.root_volume_size}"
  EBS_volume_size    = "${var.EBS_volume_size}"
  cloudwatch_logs_role_name = "${module.IAM.CloudWatchLogsRole_name}"
}
