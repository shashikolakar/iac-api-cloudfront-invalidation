data "aws_lambda_function" "lambda" {
  function_name = var.function_name
}

data "aws_caller_identity" "current" {}

data "aws_wafv2_web_acl" "acl" {
  name  = var.web_acl_name
  scope = "REGIONAL"
}