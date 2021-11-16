variable "collections" {
  type    = list(string)
  default = []
}

variable "parsers" {
  type    = list(string)
  default = []
}

variable "acquis" {
  type    = string
  default = ""
}
variable "cloudwatch_group_name" {
  type = string
}

variable "captcha_secret" {
  type = string
}

variable "profiles" {
  type    = string
  default = ""
}

variable "config" {
  type    = string
  default = ""
}

variable "scenarios" {
  type    = list(string)
  default = []
}

variable "aws_apigateway_id" {
  type    = string
  default = ""
}

variable "aws_apigateway_api_execution_arn" {
  type    = string
  default = ""
}