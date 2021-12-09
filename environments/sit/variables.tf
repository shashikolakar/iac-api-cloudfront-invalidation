variable "api_name" {
  type        = string
  description = "Name of the API"
}

variable "function_name" {
  description = "lambda function to Invalidation CloudFront"
  type        = string
}
variable "endpoint_type" {
  type        = string
  description = "Endpoint type of the API"
}

variable "http_method" {
  type        = string
  description = "HTTP Method For REST API"
}

variable "my_region" {
  type        = string
 description = "My Region"
}


variable "stage_name" {
  type        = string
  description = "My Region"
}

variable "log_retention" {
  description = "My Region"

}

variable "authorization" {
  type        = string
  description = "authorization for api gateway"
}

variable "api_key_name" {
  type        = string
  description = "Name of the api key"
}

variable "domain_name" {
  type        = string
  description = "Custom Domain Name"
}

variable "base_path" {
  type        = string
  description = "Base path"
}

variable "web_acl_name" {
  description = "Web ACL name"
  type = string
}

variable "region" {
  description = "AWS region"
  type        = string
}