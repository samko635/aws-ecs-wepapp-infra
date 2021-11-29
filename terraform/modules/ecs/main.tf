# VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# All subnet IDs
data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Tier = "Private"
  }
}

# ECS cluster
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

# ECS service
resource "aws_ecs_service" "nginx_webapp" {
  name            = "nginx_webapp"
  cluster         = aws_ecs_cluster.webapps_cluster.id
  task_definition = aws_ecs_task_definition.nginx_demo.arn
  desired_count   = 3
  # iam_role        = aws_iam_role.ecs_svc_role.arn
  # depends_on      = [aws_iam_role_policy.foo]

  network_configuration {
    subnets = data.aws_subnet_ids.private.ids
    security_groups = [ aws_security_group.ecs_sg.id ]
  }

  # ordered_placement_strategy {
  #   type  = "binpack"
  #   field = "cpu"
  # }

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }
}

# ECS task definition
resource "aws_ecs_task_definition" "nginx_demo" {
  family = "service"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = 256
  memory    = 512
  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginxdemos/hello"
      cpu       = 10
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

# IAM -----------------------
# resource "aws_iam_role" "ecs_svc_role" {
#   name = "nginx-webapp-ecs-role"

#   assume_role_policy = <<EOF
# {
#     "Version": "2008-10-17",
#     "Statement": [{
#         "Sid": "",
#         "Effect": "Allow",
#         "Principal": {
#             "Service": "ecs.amazonaws.com"
#         },
#         "Action": "sts:AssumeRole"
#     }]
# }
# EOF
# }

# Attach AmazonEC2ContainerServiceRole policy to the new role
# resource "aws_iam_role_policy_attachment" "ecs_svc_role_policy" {
#   role       = "${aws_iam_role.ecs_svc_role.name}"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
# }

# resource "aws_cloudwatch_log_group" "svc" {
#   count = "${length(var.log_groups)}"
#   name  = "${element(var.log_groups, count.index)}"
#   tags  = "${merge(var.tags, map("Name", format("%s", var.name)))}"
# }

# ECS security group
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "ECS SecurityGroup"
  vpc_id      = data.aws_vpc.main.id

  tags = {
    Name = "ECS SecurityGroup"
  }
}

# ECS security group ingress rule
resource "aws_security_group_rule" "ecs_sg_ingress" {
    type                     = "ingress"
    from_port                = 80
    to_port                  = 80
    protocol                 = "tcp"
    source_security_group_id = var.alb_security_group_id
    security_group_id        = aws_security_group.ecs_sg.id
}

# ECS security group egress rule
resource "aws_security_group_rule" "ecs_sg_egress" {
    type                     = "egress"
    from_port                = 0
    to_port                  = 0
    protocol                 = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id        = aws_security_group.ecs_sg.id
}