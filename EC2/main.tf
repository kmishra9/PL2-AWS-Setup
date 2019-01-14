data "aws_ami" "cis_ami"  {
  most_recent = true
  owners = []
  name_regex = "CIS Ubuntu Linux 18.04 LTS Benchmark Level 1"
}

resource "aws_instance" "analysis_instance" {
  count         = 1
  ami           = "${data.aws_ami.cis_ami.id}"
  instance_type = "t2.micro"
  availability_zone = "${local.region}${local.availability_zone}"
  vpc_security_group_ids = ""

  tags = {
    Name = "Analysis Instance"
  }
}
