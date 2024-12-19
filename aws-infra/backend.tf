terraform {
  backend "s3" {
    access_key = ""
    secret_key = " "
    bucket = "my-tf-test-bucket-for-terrafom-project"
    region = "ap-south-1"
    key = "aws-infra/terraform.tfstate" 
  }
}