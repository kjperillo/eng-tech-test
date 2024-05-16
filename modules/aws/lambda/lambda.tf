variable "tech_test_bucket_arn" {
  type = string
}

variable "tech_test_bucket_id" {
  type = string
}

data "aws_caller_identity" "current" {}

# Zip file for Lambda function
data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/code/file_echo.py"
  output_path = "${path.module}/code/file_echo.zip"
}

resource "aws_iam_role" "file_echo_exec_role" {
  name = "file_echo_exec_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "lambda_s3_policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Describe*",
                "s3-object-lambda:Get*",
                "s3-object-lambda:List*"
            ],
            "Resource": "*"
        }
      ]
    })
  }
}

resource "aws_lambda_function" "s3_event_lambda" {
  filename         = data.archive_file.lambda.output_path
  function_name    = "s3_event_echo_file"
  role             = aws_iam_role.file_echo_exec_role.arn
  handler          = "file_echo.lambda_handler"
  runtime          = "python3.12"

  tags = {
    Client  = "iDentify"
    Project = "identify-tech-test"
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_event_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.tech_test_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.tech_test_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_event_lambda.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".txt"
  }
}

resource "aws_s3_bucket_policy" "update_bucket_policy" {
  bucket = var.tech_test_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "s3:*"
        Principal = "*"
        Resource = [
          "${var.tech_test_bucket_arn}",
          "${var.tech_test_bucket_arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Effect = "Allow"
        Action = "s3:*"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = [
          "${var.tech_test_bucket_arn}",
          "${var.tech_test_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = "s3:GetObject"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/file_echo_exec_role"
        }
        Resource = [
          "${var.tech_test_bucket_arn}/*"
        ]
      }
    ]
  })
}
