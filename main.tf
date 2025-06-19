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

###sg instance###

resource "aws_instance" "blog" {
  ami = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [module.security-group.security_group_id]
}

####
###############
resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
vpc_security_group_ids = [aws_security_group.blog.id]
  tags = {
    Name = "jht"
  }
}
#####Secutiry group ########
resource "aws_security_group" "blog" {
  name = "blog"
  description = "Allo http and https. Allow everything out"
  vpc_id = data.aws_vpc.default.id

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
  cidr_blocks = [ "0.0.0.0/0" ]
}
##########Module###############
module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name = "jht-new"

  vpc_id = data.aws_vpc.default.id
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules =["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
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
