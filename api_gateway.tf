resource "aws_api_gateway_stage" "fastapi_agw_stage" {
  depends_on = [aws_cloudwatch_log_group.fastapi_agw_log_group]
  stage_name = var.stage
  rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
  deployment_id = aws_api_gateway_deployment.fastapi_deployment.id

  # ... other configuration ...
}

resource "aws_api_gateway_rest_api" "fastapi_gateway" {
  name        = "fastapi-serverless-api-gateway-${var.stage}"
  description = "FastApi Serverless API Gateway"
}

output "base_url" {
  value = aws_api_gateway_deployment.fastapi_deployment.invoke_url
}

resource "aws_api_gateway_resource" "fastapi_resource" {
  rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
  parent_id   = aws_api_gateway_rest_api.fastapi_gateway.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "fastapi_method" {
  rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
  resource_id   = aws_api_gateway_resource.fastapi_resource.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method_settings" "fastapi_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
  stage_name  = aws_api_gateway_stage.fastapi_agw_stage.stage_name
  method_path = "${aws_api_gateway_resource.fastapi_resource.path_part}/${aws_api_gateway_method.fastapi_method.http_method}"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

resource "aws_api_gateway_integration" "fastapi_integration" {
  rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
  resource_id = aws_api_gateway_method.fastapi_method.resource_id
  http_method = aws_api_gateway_method.fastapi_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fastapi_lambda.invoke_arn
}

resource "aws_api_gateway_method" "fastapi_proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
  resource_id   = aws_api_gateway_rest_api.fastapi_gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fastapi_integration_root" {
  rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
  resource_id = aws_api_gateway_method.fastapi_proxy_root.resource_id
  http_method = aws_api_gateway_method.fastapi_proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fastapi_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "fastapi_deployment" {
  depends_on = [
    aws_api_gateway_integration.fastapi_integration,
    aws_api_gateway_integration.fastapi_integration_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
  stage_name  = aws_api_gateway_stage.name
}

resource "aws_cloudwatch_log_group" "fastapi_agw_log_group" {
  name              = "Fastapi-Gateway-Execution-Logs_${aws_api_gateway_rest_api.fastapi_gateway.id}/${var.stage}"
  retention_in_days = 7
}