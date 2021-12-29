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
  vpc_subnet_ids         = var.create_vpc ? module.vpc.private_subnets : var.private_subnets
  vpc_security_group_ids = [module.crowdsec-sg.security_group_id]
  attach_network_policy  = true
  environment_variables = {
    LAPI_KEY              = random_password.bouncer_key.result
    GOOGLE_CAPTCHA_SECRET = var.captcha_secret
  }
  allowed_triggers = local.allowed_triggers
  publish          = true
}



resource "aws_apigatewayv2_authorizer" "gateway_authorizer" {

  count                             = var.enable_v2_authorizer ? 1 : 0
  api_id                            = var.aws_apigateway_v2_id
  authorizer_type                   = "REQUEST"
  authorizer_uri                    = module.authorizer.lambda_function_invoke_arn
  identity_sources                  = []
  name                              = "crowdsec-authorizer"
  authorizer_result_ttl_in_seconds  = 0
  authorizer_payload_format_version = "1.0"
}

resource "aws_api_gateway_authorizer" "gateway_authorizer" {
  count          = var.enable_v1_authorizer ? 1 : 0
  name           = "crowdsec-authorizer"
  rest_api_id    = var.aws_apigateway_id
  authorizer_uri = module.authorizer.lambda_function_invoke_arn
  type           = "REQUEST"
  authorizer_result_ttl_in_seconds = 0
  identity_source = ""
}
