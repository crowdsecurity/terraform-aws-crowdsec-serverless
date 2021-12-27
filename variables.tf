variable "collections" {
  type        = list(string)
  default     = []
  description = "Collections to install."
}

variable "parsers" {
  type        = list(string)
  default     = []
  description = "Parsers to install."
}

variable "acquis" {
  type        = string
  default     = ""
  description = "Path to acquis file."
}

variable "cloudwatch_group_name" {
  type        = string
  description = "Cloudwatch group to read logs"
}

variable "captcha_secret" {
  type        = string
  sensitive   = true
  description = "Recaptcha secret key"
}

variable "crowdsec_cpu" {
  type        = number
  default     = 256
  description = "Amount of vCPU units for CrowdSec task."
}

variable "crowdsec_memory" {
  type        = number
  default     = 512
  description = "Amount of memory for CrowdSec task"
}

variable "profiles" {
  type        = string
  default     = ""
  description = "Path to file containing custom Crowdsec profiles"
}

variable "config" {
  type        = string
  default     = ""
  description = "Path to file containing custom Crowdsec configration"
}

variable "scenarios" {
  type        = list(string)
  default     = []
  description = "List of scenarios to install"
}

variable "aws_apigateway_id" {
  type        = string
  default     = ""
  description = "ID of api gateway to deploy crowdsec powered authorizer"
}

variable "aws_apigateway_api_execution_arn" {
  type        = string
  default     = ""
  description = "Execution ARN of api gateway to deploy crowdsec powered authorizer"
}


variable "aws_apigateway_v2_id" {
  type        = string
  default     = ""
  description = "ID of api gateway to deploy crowdsec powered authorizer"
}

variable "enable_v2_authorizer" {
  type        = bool
  default     = false
  description = "Create authorizer for HTTP api gateway"
}

variable "enable_v1_authorizer" {
  type        = bool
  default     = false
  description = "Create authorizer for REST api gateway"
}

variable "aws_apigateway_v2_api_execution_arn" {
  type        = string
  default     = ""
  description = "Execution ARN of api gateway to deploy crowdsec powered authorizer"
}