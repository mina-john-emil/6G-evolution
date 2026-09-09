terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "sixg-evolution-tfstate"
    key            = "core/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "sixg-evolution-tflock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}
