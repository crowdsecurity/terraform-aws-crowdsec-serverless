provider "aws" {
}


module "crowdsec" {
  source                           = "../../"
  collections                      = ["crowdsecurity/apache2"]
  aws_apigateway_v2_id                = aws_apigatewayv2_api.example.id
  aws_apigateway_v2_api_execution_arn = aws_apigatewayv2_api.example.execution_arn
  cloudwatch_group_name            = module.cloudwatch_log-group.cloudwatch_log_group_name
  captcha_secret                   = "YOUR_CAPTCHA_SECRET"
  enable_v2_authorizer = true
}


module "cloudwatch_log-group" {
  source            = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version           = "2.1.0"
  name              = "API-Gateway-Execution-Logs-${aws_apigatewayv2_api.example.id}/test/"
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
      source_arn = "${aws_apigatewayv2_api.example.execution_arn}/*/*"
    },
  }
}

resource "aws_apigatewayv2_api" "example" {
  name          = "example-http-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent", "x-captcha-token"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

}

resource "aws_apigatewayv2_integration" "example" {
  api_id           = aws_apigatewayv2_api.example.id
  integration_type = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "Lambda example"
  integration_method = "POST"
  integration_uri    = module.lambda.lambda_function_invoke_arn
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.example.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = module.cloudwatch_log-group.cloudwatch_log_group_arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

resource "aws_apigatewayv2_route" "example" {
  api_id             = aws_apigatewayv2_api.example.id
  route_key          = "ANY /"
  target             = "integrations/${aws_apigatewayv2_integration.example.id}"
  authorizer_id      = module.crowdsec.aws_apigatewayv2_authorizer_id
  authorization_type = "CUSTOM"
}
