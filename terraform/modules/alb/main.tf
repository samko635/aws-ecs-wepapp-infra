# VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# All subnet IDs
data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Tier = "Public"
  }
}

# ALB
resource "aws_lb" "main_alb" {
    name               = "main-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.allow_web_traffic.id]
    subnets            = data.aws_subnet_ids.public.ids

    tags = {
        Name = "main_alb"
    }
}

# SG
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "allow_web_traffic"
  }
}

# ALB security group ingress rule
resource "aws_security_group_rule" "alb_sg_ingress" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = [data.aws_vpc.main.cidr_block]
    security_group_id        = aws_security_group.allow_web_traffic.id
}

# ALB security group egress rule
resource "aws_security_group_rule" "alb_sg_egress" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = -1
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
    security_group_id        = aws_security_group.allow_web_traffic.id
}

# Target group
resource "aws_lb_target_group" "ecs_nginx_webapp" {
  name     = "ecs-nginx-webapp"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id
}