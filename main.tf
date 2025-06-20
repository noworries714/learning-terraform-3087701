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



#######################
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jht-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  # private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

#####################




##VPC#######

data "aws_vpc" "default" {
  default = true

}

###sg instance###

resource "aws_instance" "blog" {
  ami = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [module.security-group.security_group_id]
  subnet_id = module.vpc.public_subnets[0]
    tags = {
    Name = "jht-terraforms"
  }
}

#### ALB ###

# module "alb" {
  # source = "terraform-aws-modules/alb/aws"
  # version = "~> 6.0"
  # name    = "jht-alb"
  # load_balancer_type = "applicaton"
  # vpc_id  = module.vpc.vpc_id
  # subnets = module.vpc.public_subnets

  # Security Group
  # security_group_ingress_rules = {
  #   all_http = {
  #     from_port   = 80
  #     to_port     = 80
  #     ip_protocol = "tcp"
  #     description = "HTTP web traffic"
  #     cidr_ipv4   = "0.0.0.0/0"
  #   }
  #   all_https = {
  #     from_port   = 443
  #     to_port     = 443
  #     ip_protocol = "tcp"
  #     description = "HTTPS web traffic"
  #     cidr_ipv4   = "0.0.0.0/0"
  #   }
  # }
  # security_group_egress_rules = {
  #   all = {
  #     ip_protocol = "-1"
  #     cidr_ipv4   = "10.0.0.0/16"
  #   }
  # }

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

#  target_groups = {
#     ex-instance = {
#       name_prefix      = "jht-terraform-cloud"
#       protocol         = "HTTP"
#       port             = 80
#       target_type      = "instance"
#       targets = {
#         my_target = {
#           target_id        = aws_instance.blog.id
#           port = 80
#         }
#       }
     
#     }
#   }

  # http_tcp_listeners = [ 
  #   { 
  #     port = 80
  #     protocol = http
  #     target_group_index = 0
  #   } 
  #   ]
  #   ex-https = {
  #     port            = 443
  #     protocol        = "HTTPS"
  #     certificate_arn = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"

  #     forward = {
  #       target_group_key = "ex-instance"
  #     }
  #   }
  # }

 
#   tags = {
#     Environment = "Dev"

#   }
# }

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

  # vpc_id = data.aws_vpc.default.id
  vpc_id = module.vpc.vpc_id
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

