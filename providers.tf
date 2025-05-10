# configure AWS provider
#This file configures AWS provider for terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider and set the approtiprate region
provider "aws" {
  region = "us-east-1"
}