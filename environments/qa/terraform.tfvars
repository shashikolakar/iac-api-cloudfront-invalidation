function_name             = "cf-invalidation"
api_name                  = "Purge-API"
endpoint_type             = "EDGE"
http_method               = "POST"
my_region                 = "us-east-2"
stage_name                = "qa"
log_retention             = "30"
authorization             = "NONE"
api_key_name              = "dig-qa-cf-invalidation-key"
domain_name               = "api-qa.myyellow.com"
base_path                 = "purge"
web_acl_name              = "dig-qa-api-waf"
region                    = "us-east-2"