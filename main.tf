terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "2.11.1"
    }
  }

  #   backend "s3" {
  #     bucket         = "authcendas-state-terraform"
  #     key            = "terraform.tfstate"
  #     region         = "us-east-1"
  #     dynamodb_table = "authcendas-terraform-lock"
  #     encrypt        = true
  #     profile        = "cs302"
  #   }
}
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
