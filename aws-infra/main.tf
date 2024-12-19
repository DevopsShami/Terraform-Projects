resource "aws_vpc" "myvpc" {
    cidr_block = var.cidr
    tags = {
    Name = "my-custom-vpc"
  }
  
}

resource "aws_subnet" "sub1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.sub1_cidr
    availability_zone = var.availabality_zone1
    map_public_ip_on_launch = true
     tags = {
    Name = "subnet-1"
  }

}

resource "aws_subnet" "sub2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = var.sub2_cidr
    availability_zone = var.availabality_zone2
    map_public_ip_on_launch = true
     tags = {
    Name = "subnet-2"
  }

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
   tags = {
    Name = "internet-gateway"
  }
  
  }

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.myvpc.id

    route {
        cidr_block = var.cidr_route_table
        gateway_id = aws_internet_gateway.igw.id
    }
     tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "rta1" {
    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
  
}

resource "aws_route_table_association" "rta2" {
    subnet_id = aws_subnet.sub2.id
    route_table_id = aws_route_table.RT.id
  
}

resource "aws_security_group" "mysg" {
    name = "web-sg"
    vpc_id  = aws_vpc.myvpc.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv41" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv42" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.mysg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket-for-terrafom-project"



  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_instance" "webserver1" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg.id]
    subnet_id = aws_subnet.sub1.id
    user_data = base64encode(file("userdata.sh"))
  
}

resource "aws_instance" "webserver2" {
    ami = "ami-053b12d3152c0cc71"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.mysg.id]
    subnet_id = aws_subnet.sub2.id
    user_data = base64encode(file("userdata2.sh"))
  
}

# Application load balancer script
resource "aws_lb" "mylb" {
  name               = "my-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mysg.id]
  subnets            = [aws_subnet.sub1.id ,aws_subnet.sub2.id ]



#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.id
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "tg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "target1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.mylb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "loadbalancerdns" {
    value = aws_lb.mylb.dns_name
  
}

resource "aws_iam_policy" "policy" {
  name        = "test_policy"
  path        = "/"
  description = "My test policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_s3_object" "object" {
  bucket = "my-tf-test-bucket-for-terrafom-project"
  key    = "new_object_key"
  source = "C:/Users/srish/Downloads/Srisham_SM_Resume_Software_Development.pdf"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("C:/Users/srish/Downloads/Srisham_SM_Resume_Software_Development.pdf")
}

