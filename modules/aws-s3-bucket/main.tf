resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "fastapi-serverless-${var.stage}"
  force_destroy = true

  tags = {
    Name        = "Fastapi Serverless ${var.stage}"
    Terraform   = "true"
    Environment = var.stage
  }
}
