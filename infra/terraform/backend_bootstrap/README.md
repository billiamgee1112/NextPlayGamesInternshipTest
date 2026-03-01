Bootstrap Terraform backend (S3 + DynamoDB)

This module helps you create an S3 bucket and DynamoDB table for storing Terraform state with locking.

Usage (local)

1. Configure AWS credentials in your environment (do NOT commit them):
   $env:AWS_ACCESS_KEY_ID = '<id>' ; $env:AWS_SECRET_ACCESS_KEY = '<secret>' ; $env:AWS_DEFAULT_REGION = 'us-east-1'

2. Initialize and apply the bootstrap module:
   cd infra/terraform/backend_bootstrap
   terraform init
   terraform apply -var 'bucket_name=<unique-bucket-name>' -var 'dynamodb_table_name=<unique-table-name>' -auto-approve

3. After creating the bucket/table, copy the `infra/terraform/aws/backend.example.tf` to `infra/terraform/aws/backend.tf` and replace placeholders with values returned by the module outputs.

Security notes

- Choose a globally unique S3 bucket name.
- Enable encryption and versioning (enabled by default in the module).
- Consider enabling bucket policies to restrict access to specific roles or accounts.
