####################################
# Data
####################################
data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnet_ids" "public" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Tier = "Public"
  }
}

####################################
# ALB resources
####################################
resource "aws_lb" "main_alb" {
    name               = "main-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb_sg.id]
    subnets            = data.aws_subnet_ids.public.ids

    tags = {
        Name = "main_alb"
    }
}

resource "aws_lb_target_group" "ecs_nginx_webapp" {
  name     = "ecs-nginx-webapp"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = data.aws_vpc.main.id
}

# Listener
resource "aws_lb_listener" "http_listener" {  
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = aws_lb_target_group.ecs_nginx_webapp.arn
    type             = "forward"  
  }
}
resource "aws_lb_listener_rule" "http_listener_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 100
  action {    
    type             = "forward"    
    target_group_arn = aws_lb_target_group.ecs_nginx_webapp.id
  }   
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

####################################
# Security group for ALB
####################################
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "ALB SecurityGroup"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "ALB SecurityGroup"
  }
}

resource "aws_security_group_rule" "alb_sg_ingress" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id        = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb_sg_egress" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id        = aws_security_group.alb_sg.id
}
