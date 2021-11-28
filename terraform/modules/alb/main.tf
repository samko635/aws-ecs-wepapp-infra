# VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# All subnet IDs
data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.main.id
}

# ALB
resource "aws_lb" "main_alb" {
    name               = "main-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.allow_web_traffic.id]
    subnets            = data.aws_subnet_ids.all.ids

    tags = {
        Name = "main_alb"
    }
}

# SG
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = data.aws_vpc.main.id

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 443
#     to_port          = 443
#     protocol         = "tcp"
#     cidr_blocks      = [data.aws_vpc.main.cidr_block]
#     ipv6_cidr_blocks = [data.aws_vpc.main.ipv6_cidr_block]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

  tags = {
    Name = "allow_web_traffic"
  }
}

resource "aws_security_group_rule" "alb_sg_ingress" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [data.aws_vpc.main.ipv6_cidr_block]
    security_group_id        = aws_security_group.allow_web_traffic.id
}

resource "aws_security_group_rule" "alb_sg_egress" {
    type                     = "ingress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    security_group_id        = aws_security_group.allow_web_traffic.id
}

# ALB Security group 
# module "alb_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "4.7.0"

#   name   = "main-alb-sg"
#   vpc_id = aws_vpc.main.id

#   ingress_with_cidr_blocks = [
#     {
#       rule        = "http-80-tcp"
#       cidr_blocks = "0.0.0.0/0"
#     },
#     {
#       rule        = "https-443-tcp"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   egress_with_cidr_blocks = [
#     {
#       rule        = "all-tcp"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

# }

# ALB
# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "~> 6.0"

#   name = "main-alb"
#   load_balancer_type = "application"

#   vpc_id          = aws_vpc.main.id
#   security_groups = [module.alb_sg.security_group_id]
#   subnets         = data.aws_subnet_ids.all.ids

#     http_tcp_listeners = [
#     # Forward action is default, either when defined or undefined
#     {
#       port               = 80
#       protocol           = "HTTP"
#       target_group_index = 0
#       # action_type        = "forward"
#     },
#     {
#       port        = 82
#       protocol    = "HTTP"
#       action_type = "fixed-response"
#       fixed_response = {
#         content_type = "text/plain"
#         message_body = "Fixed message"
#         status_code  = "200"
#       }
#     },
#   ]

# }
