data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

##VPC#######

data "aws_vpc" "default" {
  default = true

}
###############
resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "jht"
  }
}
#####Secutiry group ########
resource "aws_security_group" "blog" {
  name = "blog"
  description = "Allo http and https. Allow everything out"
  vpc_id = data.aws_vpc.default
}

resource "aws_security_group_rule" "blog_http_in" {
  type = "ingress"
  protocol = "tcp"
  security_group_id = aws_security_group.blog.id
  from_port = 80
  to_port = 80
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "blog_https_in" {
  type = "ingress"
  protocol = "tcp"
  security_group_id = aws_security_group.blog.id
  from_port = 443
  to_port = 443
  cidr_blocks = [ "0.0.0.0/0" ]
}

resource "aws_security_group_rule" "blog_everything_out" {
  type = "egress"
  protocol = "-1"
  security_group_id = aws_security_group.blog.id
  from_port = 0
  to_port = 0
  cidr_blocks = [ -1 ]
}
##############################



# resource "aws_instance" "db"{
#   ami           = data.aws_ami.app_ami.id
#   count = 2
#   instance_type = var.instance_type
#   tags = {
#     Name = "subs"
#   }
# }
