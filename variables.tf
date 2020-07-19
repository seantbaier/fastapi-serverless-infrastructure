variable "region" {
  description = "Default Region for Resources"
  type        = string
  default     = "us-east-1"
}

variable "stage" {
  description = "Environment to Resources are being Deployed to"
  type        = string
  default     = "dev"
}

variable "user" {
  description = "IAM User for CircleCi to Use"
  type        = string
}

variable "accountId" {
  description = "AWS AccountId"
  type        = string
}
