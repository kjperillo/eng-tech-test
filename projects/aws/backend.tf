terraform {
  backend "s3" {
    bucket         = "kperillo-terraform-backend"
    key            = "projects/iDentify-sample/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}