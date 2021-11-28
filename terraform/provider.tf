provider "aws" {
    region = "ap-southeast-2"
}

provider "gitlab" {
    token = var.gitlab_access_token
}