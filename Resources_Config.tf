resource "aws_instance" "Analysis Instance" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
}
