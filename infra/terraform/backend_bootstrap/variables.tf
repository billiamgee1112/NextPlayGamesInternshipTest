variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket for Terraform state"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the DynamoDB table for state locking"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "prevent_destroy" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
