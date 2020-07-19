# Output variable definitions

output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "s3_bucket_name" {
  description = "Name of the bucket"
  value       = aws_s3_bucket.s3_bucket.bucket
}
