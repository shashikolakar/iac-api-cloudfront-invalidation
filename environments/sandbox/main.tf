module "api" {	
  source                = "../../modules/api"	
  function_name         = var.function_name
  api_name            	= var.api_name
  endpoint_type       	= var.endpoint_type
  http_method         	= var.http_method
  my_region            	= var.my_region
  stage_name          	= var.stage_name
  log_retention       	= var.log_retention
  authorization       	= var.authorization
  api_key_name          = var.api_key_name
  domain_name           = var.domain_name
  base_path             = var.base_path
}