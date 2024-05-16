/*
  This is the main entry point for the tech test project.
  It will create the VPC, S3 bucket and Lambda function.
*/

module "vpc" {
  source = "../../modules/aws/vpc"
  tags   = var.tags
}

module "s3" {
  source = "../../modules/aws/s3"
  tags   = var.tags
}

module "lambda" {
  source               = "../../modules/aws/lambda"
  tech_test_bucket_arn = module.s3.tech_test_bucket_arn
  tech_test_bucket_id  = module.s3.tech_test_bucket_id
  tags                 = var.tags
}
