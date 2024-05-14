terraform {
  backend "s3" {
    bucket         = "kperillo-terraform-backend"
    key            = "projects/identify-tech-test/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}