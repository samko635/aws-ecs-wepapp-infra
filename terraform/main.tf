terraform {
  backend "s3" {
    bucket = "samko-tfstates"
    key    = "default/ecs-webapp"
    region = "ap-southeast-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

module "networks" {
  source = "./modules/networks"
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.networks.vpc_id
}

module "ecs" {
  source = "./modules/ecs"
  aws_lb_target_group_arn = module.alb.aws_lb_target_group_arn
  vpc_id = module.networks.vpc_id
  alb_security_group_id = module.alb.alb_security_group_id
  ecs_role = module.iam.ecs_role
}

module "autoscaling" {
  source = "./modules/autoscaling"
  ecs_cluster = module.ecs.ecs_cluster
  ecs_service = module.ecs.ecs_service
}

module "iam" {
  source = "./modules/iam"
  # alb = module.alb.alb
}

