####################################
# Data
####################################
data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  tags = {
    Tier = "Private"
  }
}

####################################
# ECS resources
####################################
resource "aws_ecs_cluster" "webapps_cluster" {
  name = "webapps_cluster"
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
    base = 0
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "nginx_webapp" {
  name            = "nginx_webapp"
  cluster         = aws_ecs_cluster.webapps_cluster.id
  task_definition = aws_ecs_task_definition.nginx_demo.arn
  desired_count   = 3

  network_configuration {
    subnets = data.aws_subnet_ids.private.ids
    security_groups = [ aws_security_group.ecs_sg.id ]
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  lifecycle {
    ignore_changes = [
      desired_count]
  }
}

resource "aws_ecs_task_definition" "nginx_demo" {
  family = "nginx_demo_service"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory    = 512
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginxdemos/hello"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

####################################
# Security group for ECS
####################################
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "ECS SecurityGroup"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "ECS SecurityGroup"
  }
}

resource "aws_security_group_rule" "ecs_sg_ingress" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = var.alb_security_group_id
    security_group_id        = aws_security_group.ecs_sg.id
}

resource "aws_security_group_rule" "ecs_sg_egress" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id        = aws_security_group.ecs_sg.id
}