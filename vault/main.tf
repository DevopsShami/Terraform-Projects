provider "aws" {
region = "ap-south-1"  
}

provider "vault" {
    address = "http://65.2.34.125:8200/:8200"
skip_child_token = true

auth_login{
    path = "auth/approle/login"

    parameters = {
      role_id = ""
      secret_id = ""
    }


}
}
data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = ""
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0dee22c13ea7a9a67"
  instance_type = "t2.micro"

  tags = {
    Name = "test"
    Secret = data.vault_kv_secret_v2.example.data["username"]
  }
}

