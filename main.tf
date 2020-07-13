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

provider "template" {
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
    s3_bucket_arn = aws_s3_bucket.fastapi_serverless_tf_state.arn
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

resource "aws_s3_bucket" "fastapi_serverless_tf_state" {
  tags = {
    Name = "Fastapi Serverless State Management ${var.stage}"
  }

  bucket        = "fastapi-serverless-tf-state-${var.stage}"
  force_destroy = true
}
