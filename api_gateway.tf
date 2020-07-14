resource "aws_api_gateway_rest_api" "fastapi_gateway" {
  name        = "fastapi-serverless-api-gateway-${var.stage}"
  description = "FastApi Serverless API Gateway"
}

output "base_url" {
  value = aws_api_gateway_deployment.fastapi_deployment.invoke_url
}
