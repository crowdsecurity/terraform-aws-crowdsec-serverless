locals {
  profiles = var.profiles != "" ? var.profiles : "${path.module}/profiles.yaml"
  acquis   = var.acquis != "" ? var.acquis : "${path.module}/acquis.yaml"
  config   = var.config != "" ? var.config : "${path.module}/config.yaml"

  # create_rest_api_authorizer = var.aws_apigateway_id != "" ? true : false
  # create_http_api_authorizer = var.aws_apigateway_v2_id != "" ? true : false

  allowed_triggers = var.aws_apigateway_id != "" ? (
    var.aws_apigateway_v2_id != "" ?
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
    var.aws_apigateway_id != "" ? {
      RESTGateway = {
        service    = "apigateway"
        source_arn = "${var.aws_apigateway_api_execution_arn}/*/*"
      },
    } : {}
  )

}
