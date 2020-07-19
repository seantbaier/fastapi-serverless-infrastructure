variable "stage" {
  description = "Environment to Resources are being Deployed to"
  type        = string
  default     = "dev"
}

variable "s3_bucket_name" {
  description = "S3 Bucket for lambda.zip to be uploade too."
  type        = string
}

variable "agw_permission_arn" {
  description = "API Gateway Execution Permission ARN"
  type        = string
}
