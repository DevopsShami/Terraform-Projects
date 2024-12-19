terraform {
  backend "s3" {
    bucket = "aws-shami-s3-bucket-two"
    region = "ap-south-1"
    key = "shami/terraform.tfstate"
    
  }
}