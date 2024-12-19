provider "aws" {
    region = "ap-south-1"
}

resource "aws_instance" "shami" {
    
    ami = var.ami_value
    instance_type = var.instance_type_value
    subnet_id = var.subnet_id_value
    associate_public_ip_address = var.public_ip_enable
  tags = { Name = var.instancename }
  
}

resource "aws_s3_bucket" "s3_buckets" {
    bucket = var.s3bucket_name
    tags = {
        Name = " My Bucket"
        Environment = "Dev"
    }
  
}

output "public_ip_vm" {
  value = aws_instance.shami.public_ip
  
}