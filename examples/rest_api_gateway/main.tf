provider "aws" {
  region = "ap-south-1"
}


# module "crowdsec" {
#   source                           = "../../"
#   collections                      = ["crowdsecurity/apache2"]
#   aws_apigateway_v2_id                = module.api_gateway.apigatewayv2_api_id
#   aws_apigateway_v2_api_execution_arn = module.api_gateway.apigatewayv2_api_execution_arn
#   cloudwatch_group_name            = module.cloudwatch_log-group.cloudwatch_log_group_name
#   captcha_secret                   = "YOUR_CAPTCHA_SECRET"
# }


# module "cloudwatch_log-group" {
#   source            = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
#   version           = "2.1.0"
#   name              = "API-Gateway-Execution-Logs-${module.api_gateway.apigatewayv2_api_id}/test/"
#   retention_in_days = 7
# }


module "lambda" {
  publish       = true
  source        = "terraform-aws-modules/lambda/aws"
  version       = "2.17.0"
  function_name = "demo_lambda_rest_api"
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


resource "aws_api_gateway_rest_api" "api" {
  name = "myapi"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "resource"
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.
}