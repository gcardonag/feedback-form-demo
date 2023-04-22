terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket         = "feedback-form-nerts2023-terraform-state"
    key            = "infra.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "feedback-form-nerts2023-terraform-state-lock"
  }
}

provider "aws" {
  region = "us-east-1"
}