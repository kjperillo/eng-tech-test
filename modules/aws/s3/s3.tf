# Description: This file contains the terraform code to create an S3 bucket with versioning enabled 
# and a bucket policy that denies unencrypted traffic and allows the account owner full access to the bucket.

# Convenience data source to get the current AWS account ID
data "aws_caller_identity" "current" {}

# S3 bucket for tech test
resource "aws_s3_bucket" "tech_test_bucket" {
  bucket        = "identify-tech-test"
  force_destroy = true
  tags          = var.tags
}

# Enable versioning on the tech test S3 bucket
resource "aws_s3_bucket_versioning" "tech_test_bucket_versioning" {
  bucket = aws_s3_bucket.tech_test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket policy for tech test S3 bucket
resource "aws_s3_bucket_policy" "tech_test_bucket_policy" {
  bucket = aws_s3_bucket.tech_test_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:*"
        Effect    = "Deny"
        Principal = "*"
        Resource = [
          "arn:aws:s3:::identify-tech-test",
          "arn:aws:s3:::identify-tech-test/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Action = "s3:*"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = [
          "arn:aws:s3:::identify-tech-test",
          "arn:aws:s3:::identify-tech-test/*"
        ]
      }
    ]
  })
}

# Output the ARN and ID of the tech test S3 bucket
output "tech_test_bucket_arn" {
  value       = aws_s3_bucket.tech_test_bucket.arn
  description = "The ARN of the tech test S3 bucket"
}

output "tech_test_bucket_id" {
  value       = aws_s3_bucket.tech_test_bucket.id
  description = "The ID of the tech test S3 bucket"

}