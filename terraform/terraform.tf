terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
  }
  backend "s3" {
    bucket         = "ebad-arshad-s3-bucket-ecommerce-tfstate"
    key            = "terraform.tfstate"
    dynamodb_table = "terraform-lock"
    encrypt        = true
    region         = "ap-south-1"
  }
}