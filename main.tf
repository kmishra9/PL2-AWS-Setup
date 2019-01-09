/* TODO:

- Build IAM users (researchers + administrators)
- Build IAM groups (researchers + log analysis + administrators)
- IAM Password Policy
- Security Token Service Regions (Deactivate pretty much everything except for US West (Oregon))
- Log Analysis (optional)
- Creating a bunch of customer-managed policies (filter by customer-managed in KaiserFlu to check)

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
  source = "./cloudtrail"
  project_name = "${var.project_name}"
  organization_name = "${var.organization_name}"
  log_export = "${var.log_export}"
  region = "${local.region}"
  stage = "${local.stage}"
}

################################################################################
# Configuring IAM users, roles, groups, and privileges

module "IAM" {
  source = "./IAM"
  project_name = "${var.project_name}"
  num_researchers = "${var.num_researchers}"
  num_admins = "${var.num_admins}"
  log_export = "${var.log_export}"
}

################################################################################
# Configuring network and firewall

# VPC Module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.50.0

# Security Group Module: https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/2.10.0

################################################################################
# Configuring the analysis instance

module "analysis_instance" {
  source = "./analysis_instance"
}
