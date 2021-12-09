resource "aws_api_gateway_rest_api" "rest_api" {
  name                    = var.api_name
  endpoint_configuration {
    types                 = [var.endpoint_type]
    }
}

resource "aws_api_gateway_method" "method" {
  depends_on              = [aws_api_gateway_rest_api.rest_api]
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method             = var.http_method
  authorization           = var.authorization
  api_key_required        = true
  request_models          = {
    "application/json" = "Empty"
    }
}

resource "aws_api_gateway_integration" "integration" {
  depends_on              = [aws_api_gateway_method.method]
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method             = var.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = data.aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_method_response" "http_status_value" {
  depends_on              = [aws_api_gateway_integration.integration]
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_rest_api.rest_api.root_resource_id
  http_method             = var.http_method
  status_code             = "200"
  response_models         = {
    "application/json" = "Empty"
    }
}


resource "aws_lambda_permission" "permission" {
  depends_on              = [aws_api_gateway_rest_api.rest_api]
  statement_id_prefix     = "AllowExecutionFromAPIGateway"
  action                  = "lambda:InvokeFunction"
  function_name           = data.aws_lambda_function.lambda.function_name
  principal               = "apigateway.amazonaws.com" 
  source_arn              = "arn:aws:execute-api:${var.my_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${var.http_method}/"
  lifecycle {
    create_before_destroy = true
    }
}

resource "aws_api_gateway_stage" "stage" {
  depends_on           = [aws_cloudwatch_log_group.log_group]
  deployment_id        = aws_api_gateway_deployment.deployment.id
  rest_api_id          = aws_api_gateway_rest_api.rest_api.id
  stage_name           = var.stage_name
  xray_tracing_enabled = true
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on              = [aws_api_gateway_method.method, aws_api_gateway_integration.integration, aws_lambda_permission.permission]
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  triggers                = {
    redeployment          = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
    }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_kms_key" "cloudwatch_log_encryption_key" {
  description         = "KMS key for encrypting ${aws_api_gateway_rest_api.rest_api.id}/${var.stage_name} log group"
  enable_key_rotation = true
  policy              = templatefile("${path.module}/kms_key_policy/policy.tpl", local.log_group_policy_vars)
}

resource "aws_cloudwatch_log_group" "log_group" {
  name                    = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${var.stage_name}"
  retention_in_days       = var.log_retention
  kms_key_id              = aws_kms_key.cloudwatch_log_encryption_key.arn
}

resource "aws_api_gateway_method_settings" "stage" {
  depends_on              = [aws_api_gateway_deployment.deployment]
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  stage_name              = aws_api_gateway_stage.stage.stage_name
  method_path             = "*/*"
  settings {
    metrics_enabled       = true
    logging_level         = "INFO"
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name                    = var.api_key_name
}
 
resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  depends_on              = [aws_api_gateway_deployment.deployment]
  name                    = "${var.api_name}-usage-plan"
  api_stages {
    api_id                = aws_api_gateway_rest_api.rest_api.id
    stage                 = aws_api_gateway_stage.stage.stage_name
  }
}
 
resource "aws_api_gateway_usage_plan_key" "usage_plan_key" {
  depends_on              = [aws_api_gateway_deployment.deployment,aws_api_gateway_usage_plan.api_usage_plan]
  key_id                  = aws_api_gateway_api_key.api_key.id
  key_type                = "API_KEY"
  usage_plan_id           = aws_api_gateway_usage_plan.api_usage_plan.id
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  depends_on  = [aws_api_gateway_deployment.deployment]
  api_id      = aws_api_gateway_rest_api.rest_api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = var.domain_name
  base_path   = var.base_path
}

resource "aws_wafv2_web_acl_association" "web_acl_association" {
  resource_arn = aws_api_gateway_stage.stage.arn
  web_acl_arn  = data.aws_wafv2_web_acl.acl.arn
}