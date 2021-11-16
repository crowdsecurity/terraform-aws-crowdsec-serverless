module "authorizer" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "2.17.0"
  function_name = "crowdsecauthorizer"
  description   = "Authorizer for GW"
  handler       = "index.handler"
  runtime       = "python3.8"
  source_path = [
    {
      path             = "${path.module}/authorizer"
      pip_requirements = true,
    }
  ]
  build_in_docker        = true
  vpc_subnet_ids         = module.vpc.private_subnets
  vpc_security_group_ids = [module.crowdsec-sg.security_group_id]
  attach_network_policy  = true
  environment_variables = {
    LAPI_KEY = random_string.bouncer_key.id
    GOOGLE_CAPTCHA_SECRET = var.captcha_secret
  }
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${var.aws_apigateway_api_execution_arn}/*/*"
    },
  }
  publish = true
}

resource "aws_apigatewayv2_authorizer" "gateway_authorizer" {
  count                             = var.aws_apigateway_id == "" ? 0 : 1
  api_id                            = var.aws_apigateway_id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = module.authorizer.lambda_function_invoke_arn
  identity_sources                  = []
  name                              = "crowdsec-authorizer"
  authorizer_result_ttl_in_seconds  = 0
  authorizer_payload_format_version = "1.0"
}
