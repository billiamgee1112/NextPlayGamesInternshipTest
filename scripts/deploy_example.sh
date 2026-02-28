#!/usr/bin/env bash
# Example script to run terraform apply for AWS
set -e
cd infra/terraform/aws
terraform init
terraform apply -auto-approve
