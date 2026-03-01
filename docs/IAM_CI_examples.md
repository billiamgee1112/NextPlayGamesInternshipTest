CI IAM policy examples (least privilege)

This file contains example IAM policies for CI to perform ECR/GHCR push and Terraform backend bootstrap. Use these as starting points and restrict principals and resources to your account.

1) Policy for bootstrapping S3 + DynamoDB (backend bootstrap)

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:PutEncryptionConfiguration",
        "s3:PutBucketVersioning",
        "s3:PutBucketAcl",
        "s3:PutBucketTagging",
        "s3:PutBucketPolicy",
        "s3:PutObject",
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::<your-terraform-state-bucket>"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:CreateTable",
        "dynamodb:DescribeTable",
        "dynamodb:PutItem",
        "dynamodb:UpdateTable",
        "dynamodb:ListTables"
      ],
      "Resource": "arn:aws:dynamodb:<region>:<account-id>:table/<your-lock-table>"
    }
  ]
}

2) Policy for CI to push images to ECR (if using ECR instead of GHCR)

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:PutImage",
        "ecr:CreateRepository",
        "ecr:DescribeRepositories"
      ],
      "Resource": "*"
    }
  ]
}

3) Policy for Terraform apply (minimal example)

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:RegisterTaskDefinition",
        "ecs:CreateService",
        "iam:PassRole",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:CreateListener",
        "s3:PutObject",
        "dynamodb:PutItem"
      ],
      "Resource": "*"
    }
  ]
}
