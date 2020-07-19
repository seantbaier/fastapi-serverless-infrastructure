variable "stage" {
  description = "Environment to Resources are being Deployed to"
  type        = string
  default     = "dev"
}

variable "invoke_arn" {
  description = "ARN of the Lambda to Invoke on all Requests"
  type        = string
}
