terraform {
  backend "s3" {
    bucket         = "sandbox-poc-terraform-states"
    key            = "iac-api-cloudfront-invalidation/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
  }
}