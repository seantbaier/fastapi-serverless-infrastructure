output "base_url" {
  value = aws_api_gateway_deployment.fastapi_deployment.invoke_url
}

output "execution_arn" {
  description = "Execution ARN for the Lambda Api Gateway will Invoke"
  value       = aws_api_gateway_rest_api.fastapi_gateway.execution_arn
}
