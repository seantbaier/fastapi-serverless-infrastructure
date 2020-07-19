# Output variable definitions

output "invoke_arn" {
  description = "Invoke ARN of the Lambda"
  value       = aws_lambda_function.fastapi_lambda.invoke_arn
}

output "lambda_arn" {
  description = "ARN of the Lambda"
  value       = aws_lambda_function.fastapi_lambda.arn
}
