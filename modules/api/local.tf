locals {
  log_group_policy_vars = {
    region         = var.region
    account_id     = tostring(data.aws_caller_identity.current.account_id)
    log_group_name = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.rest_api.id}/${var.stage_name}"
  }
  
}