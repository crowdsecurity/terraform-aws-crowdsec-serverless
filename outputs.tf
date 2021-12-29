output "aws_apigatewayv2_authorizer_id" {
  value = one(aws_apigatewayv2_authorizer.gateway_authorizer[*].id)
}

output "aws_apigatewayv1_authorizer_id" {
  value = one(aws_api_gateway_authorizer.gateway_authorizer[*].id)
}
