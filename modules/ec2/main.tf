data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}




resource "aws_instance" "server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  availability_zone = var.availability_zone
  security_groups = var.security_groups
  subnet_id = var.subnet_id

  tags = {
    Name = "Terraform-Lab-Instance-dev"
  }
}
