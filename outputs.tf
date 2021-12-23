output "aws_apigatewayv2_authorizer_id" {
  value = length(aws_apigatewayv2_authorizer.gateway_authorizer) ==1 ? aws_apigatewayv2_authorizer.gateway_authorizer[0].id : ""
}
