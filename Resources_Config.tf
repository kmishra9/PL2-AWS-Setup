/* TODO:

- Add pieces on retrieving the access key and secret key from the IAM user upon creation

- Build IAM users (researchers + administrators)
- Build IAM groups (researchers + log analysis + administrators)
- IAM Password Policy
- Security Token Service Regions (Deactivate pretty much everything except for US West (Oregon))
- Log Analysis (optional)
- Creating a bunch of customer-managed policies (filter by customer-managed in KaiserFlu to check)

- Adding provisioners for iptable setup, ssh tunnel creation, users being added (docs: https://www.terraform.io/docs/provisioners/index.html)
  - The file provisioner in particular would be a nice way to port scripts from the github repo to the instance
  - local-exec will be useful once scripts have been deposited in the appropriate -- you can interpolate resource variables (such as VPC ips, which should be useful for iptables setup)

- What is security hub and how should I use it?
- Do I still need an elastic IP if I'm connecting within the VPC?
*/

# Configuring the environment

# Configuring IAM users for researchers & administrators

# Configuring the analysis instance
data "aws_ami" "cis_ami"  {
  most_recent = true
  owners = []
  name_regex = "CIS Ubuntu Linux 18.04 LTS Benchmark Level 1"
}

resource "aws_instance" "analysis_instance" {
  count         = 1
  ami           = "${data.aws_ami.cis_ami.id}"
  instance_type = "t2.micro"
  availability_zone =

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name = "Analysis Instance"
  }
}

resource "aws_eip" "analysis_instance_eip" {
  vpc              = true
  instance         = "${aws_instance.analysis_instance.id}"
}
