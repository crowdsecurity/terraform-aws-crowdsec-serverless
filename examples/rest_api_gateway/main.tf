provider "aws" {
}

module "crowdsec" {
  source                           = "../../"
  collections                      = ["crowdsecurity/apache2"]
  enable_v1_authorizer             = true
  aws_apigateway_id                = aws_api_gateway_rest_api.api.id
  aws_apigateway_api_execution_arn = aws_api_gateway_rest_api.api.execution_arn
  cloudwatch_group_name            = module.cloudwatch_log-group.cloudwatch_log_group_name
  captcha_secret                   = "YOUR_CAPTCHA_SECRET"
}

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
      source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
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
  authorization = "CUSTOM"
  authorizer_id = module.crowdsec.aws_apigatewayv1_authorizer_id
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_function_invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_method.method
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
}

module "cloudwatch_log-group" {
  source            = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version           = "2.1.0"
  name              = "API-Gateway-Execution-Logs-${aws_api_gateway_rest_api.api.id}/test/"
  retention_in_days = 7
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_stage" "api_stage" {
  stage_name    = "v1"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  access_log_settings {
    destination_arn = module.cloudwatch_log-group.cloudwatch_log_group_arn
    format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
  }
}

