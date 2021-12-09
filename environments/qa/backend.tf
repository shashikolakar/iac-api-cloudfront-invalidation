terraform {
  backend "s3" {
    bucket         = "dig-qa-iac-state"
    key            = "iac-api-cloudfront-invalidation/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "dig-iac-state-lock"
  }
}