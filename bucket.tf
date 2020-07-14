resource "aws_s3_bucket" "fastapi_serverless" {
  tags = {
    Name = "Fastapi Serverless ${var.stage}"
  }

  bucket        = "fastapi-serverless-${var.stage}"
  force_destroy = true
}
