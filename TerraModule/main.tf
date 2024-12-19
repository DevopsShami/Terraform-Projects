provider "aws" {
    region = "ap-south-1"
  
}

module "ec2_instance" {
   source = "./module-ec2_instance" 
   ami_value = "ami-0dee22c13ea7a9a67"
  subnet_id_value = "subnet-091eccd06b20f6c70"
  instance_type_value = "t2.micro"
  public_ip_enable = "true"
vmname = "testone"
  
  
}

output "public-ip-vm" {
value = module.ec2_instance.public-ip-address
}


