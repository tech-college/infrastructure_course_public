provider "aws" {
  region  = "ap-northeast-1"
  profile = "tech-college"
}

provider "github" {
  token = "YOUR-GITHUB-TOKEN"
  owner = "YOUR-OWNER-NAME"
}

terraform {
  required_version = "1.4.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
}