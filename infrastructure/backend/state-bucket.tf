####################################################################################
# PROVIDERS
####################################################################################

terraform {
  required_version = "1.1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

####################################################################################
# KMS 
# To encrypt bucket
####################################################################################

resource "aws_kms_key" "terraform_state_bucket_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  tags = {
    ManagedBy = "Terraform"
    Owner     = "Comphass"
    CreatedAt = "2022-12-29"
  }
}

resource "aws_kms_alias" "terraform_state_bucket_key_alias" {
  name          = "alias/terraform-remote-state-key"
  target_key_id = aws_kms_key.terraform_state_bucket_key.key_id
}

####################################################################################
# S3 BUCKET REMOTE STATE
####################################################################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = "comphass-terraform-state-backend"

  tags = {
    Description = "Stores terraform remote state files"
    ManagedBy   = "Terraform"
    Owner       = "Comphass"
    CreatedAt   = "2022-12-29"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_acl" "terraform_state_acl" {
  bucket = aws_s3_bucket.terraform_state.id
  acl    = "private"
}

# Enable versioning so we can see the full revision history of our
# state files
resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-state-lock-${aws_s3_bucket.terraform_state.bucket}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    ManagedBy = "Terraform"
    Owner     = "Comphass"
    CreatedAt = "2022-12-29"
  }
}

####################################################################################
# OUTPUTS
####################################################################################

output "kms_key_arn" {
  value = aws_kms_key.terraform_state_bucket_key.arn
}

output "kms_key_key_id" {
  value = aws_kms_key.terraform_state_bucket_key.key_id
}

output "kms_key_alias_name" {
  value = aws_kms_alias.terraform_state_bucket_key_alias.name
}

output "kms_key_alias_id" {
  value = aws_kms_alias.terraform_state_bucket_key_alias.id
}

output "remote_state_bucket" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "remote_state_bucket_arn" {
  value = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_name" {
  value = aws_dynamodb_table.terraform_locks.name
}

output "dynamodb_id" {
  value = aws_dynamodb_table.terraform_locks.id
}