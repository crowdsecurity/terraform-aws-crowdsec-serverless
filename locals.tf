locals {
  profiles = var.profiles != "" ? var.profiles : "${path.module}/profiles.yaml"
  acquis   = var.acquis != "" ? var.acquis : "${path.module}/acquis.yaml"
  config   = var.config != "" ? var.config : "${path.module}/config.yaml"

  allowed_triggers = var.enable_v1_authorizer ? (
    var.enable_v2_authorizer  ?
    {
      HTTPGateway = {
        service    = "apigateway"
        source_arn = "${var.aws_apigateway_v2_api_execution_arn}/*/*"
      },
      RESTGateway = {
        service    = "apigateway"
        source_arn = "${var.aws_apigateway_api_execution_arn}/*/*"
      },
      } : {
      RESTGateway = {
        service    = "apigateway"
        source_arn = "${var.aws_apigateway_api_execution_arn}/*/*"
      },
    }
    ) : (
    var.enable_v2_authorizer  ? {
      HTTPGateway = {
        service    = "apigateway"
        source_arn = "${var.aws_apigateway_v2_api_execution_arn}/*/*"
      },
    } : {}
  )

}
