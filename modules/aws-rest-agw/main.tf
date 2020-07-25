resource "aws_api_gateway_stage" "fastapi_agw_stage" {
  # depends_on    = [aws_cloudwatch_log_group.fastapi_agw_log_group]
  stage_name    = var.stage
  rest_api_id   = aws_api_gateway_rest_api.fastapi_gateway.id
  deployment_id = aws_api_gateway_deployment.fastapi_deployment.id
}

resource "aws_api_gateway_rest_api" "fastapi_gateway" {
  name        = "fastapi-serverless-api-gateway-${var.stage}"
  description = "FastApi Serverless API Gateway"
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
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"
  }
}

resource "aws_api_gateway_integration" "fastapi_integration" {
  rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
  resource_id = aws_api_gateway_method.fastapi_method.resource_id
  http_method = aws_api_gateway_method.fastapi_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
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
  uri                     = var.invoke_arn
}

resource "aws_api_gateway_deployment" "fastapi_deployment" {
  depends_on = [
    aws_api_gateway_integration.fastapi_integration,
    # aws_api_gateway_integration.fastapi_integration_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.fastapi_gateway.id
  stage_name  = "dev"
}

# IAM role which dictates what other AWS services the API Gateway may access.
resource "aws_iam_role" "agw_log_role" {
  name = "fastapi-agw-log-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "agw_role_attach" {
  role       = aws_iam_role.agw_log_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
