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
