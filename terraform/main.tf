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

resource "gitlab_project_variable" "sample" {
  project = data.gitlab_project.aws_ecs_webapp_infra_project.id
  key = "sample" 
  value = "Greetings Earthlings!" 
}
