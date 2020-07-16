resource "aws_api_gateway_rest_api" "fastapi_gateway" {
  name        = "fastapi-serverless-api-gateway-${var.stage}"
  description = "FastApi Serverless API Gateway"
}

output "base_url" {
  value = aws_api_gateway_deployment.fastapi_deployment.invoke_url
}

resource "aws_cloudwatch_log_group" "fastapi_gateway_log_group" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.fastapi_gateway.id}/${var.stage}"
  retention_in_days = 7
}