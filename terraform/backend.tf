terraform {
  backend "s3" {
    bucket = "dlnews-backend-eucentral1-473178649040-dev"
    key    = "uff-ic/s3/terraform.tfstate"
    region = "eu-central-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
