module "vpc" {
    source = "../../modules/aws/vpc"
}

module "s3" {
  source = "../../modules/aws/s3"
}

module "lambda" {
  source = "../../modules/aws/lambda"
  tech_test_bucket_arn = module.s3.tech_test_bucket_arn
  tech_test_bucket_id  = module.s3.tech_test_bucket_id
}
