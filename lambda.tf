resource "aws_lambda_function" "fastapi_lambda" {
  function_name = "fastapi-serverless-${var.stage}"

  # The bucket name as created earlier with "aws s3api create-bucket"
  s3_bucket = aws_s3_bucket.fastapi_serverless.bucket
  s3_key    = "v1.0.0/function.zip"

  # "main" is the filename within the zip file (main.js) and "handler"
  # is the name of the property under which the handler function was
  # exported in that file.
  handler = "main.handler"
  runtime = "python3.7"

  role = aws_iam_role.lambda_exec.arn
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "fastapi-lambda-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "lambda_role_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
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
  stage_name  = "dev"
}

resource "aws_lambda_permission" "fastapi_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fastapi_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.fastapi_gateway.execution_arn}/*/*"
}
