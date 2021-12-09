terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.43.0"
    }
  }
  required_version = "0.14.10"
}

provider "aws" {
  region     = "us-east-2"

}