data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "tech_test_bucket" {
  bucket = "identify-tech-test"
  force_destroy = true
  tags = {
    Client  = "iDentify"
    Project = "identify-tech-test"
  }
}

resource "aws_s3_bucket_versioning" "tech_test_bucket_versioning" {
  bucket = aws_s3_bucket.tech_test_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "tech_test_bucket_policy" {
  bucket = aws_s3_bucket.tech_test_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:*"
        Effect    = "Deny"
        Principal = "*"
        Resource  = [
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
        Action    = "s3:*"
        Effect    = "Allow"
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

output "tech_test_bucket_arn" {
  value = aws_s3_bucket.tech_test_bucket.arn
  description = "The ARN of the tech test S3 bucket"
}

output "tech_test_bucket_id" {
  value = aws_s3_bucket.tech_test_bucket.id
  description = "The ID of the tech test S3 bucket"
  
}