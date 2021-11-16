provider "aws" {
  region = "ap-south-1"
}


module "crowdsec" {
  source                           = "./modules/crowdsec"
  collections                      = ["crowdsecurity/apache2"]
  aws_apigateway_id                = module.api_gateway.apigatewayv2_api_id
  aws_apigateway_api_execution_arn = module.api_gateway.apigatewayv2_api_execution_arn
  cloudwatch_group_name            = module.cloudwatch_log-group.cloudwatch_log_group_name
}


module "cloudwatch_log-group" {
  source            = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version           = "2.1.0"
  name              = "API-Gateway-Execution-Logs-${module.api_gateway.apigatewayv2_api_id}/test/"
  retention_in_days = 7
}


module "lambda" {
  publish       = true
  source        = "terraform-aws-modules/lambda/aws"
  version       = "2.17.0"
  function_name = "demolambda"
  description   = "Lambda secured by Crowdsec"
  handler       = "index.handler"
  runtime       = "python3.8"
  source_path = [
    {
      path             = "./lambda"
      pip_requirements = true,
    }
  ]
  build_in_docker = true
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${module.api_gateway.apigatewayv2_api_execution_arn}/*/*"
    },
  }
}

// api gateway
module "api_gateway" {
  source                 = "terraform-aws-modules/apigateway-v2/aws"
  create_api_domain_name = false
  name                   = "testapi"
  description            = "My awesome HTTP API Gateway"
  protocol_type          = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent", "x-captcha-token"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  # Access logs
  default_stage_access_log_destination_arn = module.cloudwatch_log-group.cloudwatch_log_group_arn
  default_stage_access_log_format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"

  # Routes and integrations
  integrations = {
    "GET /" = {
      lambda_arn             = module.lambda.lambda_function_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
      authorization_type     = "CUSTOM"
      authorizer_id          = module.crowdsec.aws_apigatewayv2_authorizer_id
    }
  }
}

