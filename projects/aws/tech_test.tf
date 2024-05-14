module "vpc" {
    source = "../../modules/vpc"
}

module "s3" {
  source = "../../modules/s3"
}

module "lambda" {
  source = "../../modules/lambda"
  tech_test_bucket_arn = module.s3.tech_test_bucket_arn
  tech_test_bucket_id  = module.s3.tech_test_bucket_id
}
