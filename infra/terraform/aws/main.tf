// AWS Terraform module skeleton
terraform {
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.region
}

// Example: VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "example-vpc"
  }
}

// Example: ECS cluster
resource "aws_ecs_cluster" "this" {
  name = "example-cluster"
}

// Example: RDS Postgres (minimal, for illustration)
resource "aws_db_subnet_group" "default" {
  name       = "example-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = var.db_instance_class
  identifier           = var.db_identifier
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  skip_final_snapshot  = true
}
