terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "seanbaier"

    workspaces {
      name = "fastapi-serverless-infrastructure"
    }
  }
}

provider "aws" {
  region = var.region
}

module "aws_s3_bucket" {
  source = "./modules/aws-s3-bucket"

  stage = var.stage
}


module "aws_api_gateway_rest_api" {
  source = "./modules/aws-rest-agw"

  stage      = var.stage
  invoke_arn = module.aws_lambda_function.invoke_arn
}

module "aws_lambda_function" {
  source = "./modules/aws-lambda"

  stage              = var.stage
  s3_bucket_name     = module.aws_s3_bucket.s3_bucket_name
  agw_permission_arn = module.aws_api_gateway_rest_api.execution_arn
}


resource "aws_iam_user" "circleci" {
  name = var.user
  path = "/system/"
}

resource "aws_iam_access_key" "circleci" {
  user = aws_iam_user.circleci.name
}

data "template_file" "circleci_policy" {
  template = file("circleci_s3_access.tpl.json")

  vars = {
    s3_bucket_arn = module.aws_s3_bucket.arn
    lambda_arn    = module.aws_lambda_function.lambda_arn
  }
}

resource "local_file" "circle_credentials" {
  filename = "tmp/circleci_credentials"
  content  = "${aws_iam_access_key.circleci.id}\n${aws_iam_access_key.circleci.secret}"
}

resource "aws_iam_user_policy" "circleci" {
  name   = "AllowCircleCI"
  user   = aws_iam_user.circleci.name
  policy = data.template_file.circleci_policy.rendered
}
