// Example backend configuration for Terraform remote state using S3 + DynamoDB (do NOT check secrets into repo)

terraform {
  backend "s3" {
    bucket         = "<your-terraform-state-bucket>"
    key            = "project/terraform.tfstate"
    region         = "<your-aws-region>"
    dynamodb_table = "<your-lock-table>" // optional, for state locking
    encrypt        = true
  }
}

// Usage:
// 1. Create an S3 bucket and DynamoDB table in your AWS account.
// 2. Configure the following environment variables locally or in CI as repository secrets:
//    - AWS_ACCESS_KEY_ID
//    - AWS_SECRET_ACCESS_KEY
//    - AWS_DEFAULT_REGION
// 3. Run: terraform init
// 4. To avoid accidentally writing to a remote backend during PR checks, the CI uses "terraform init -backend=false" for pull requests.

// Example Terraform commands for local use (PowerShell):
// $env:AWS_ACCESS_KEY_ID = '<id>' ; $env:AWS_SECRET_ACCESS_KEY = '<secret>' ; $env:AWS_DEFAULT_REGION = 'us-east-1'
// terraform init
// terraform plan -out=tfplan
// terraform apply tfplan
