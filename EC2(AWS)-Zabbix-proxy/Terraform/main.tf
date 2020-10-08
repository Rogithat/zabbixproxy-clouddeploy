
provider "aws" {
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  shared_credentials_file = "your_credentials_file"
  profile                 = "default"
}

resource "aws_security_group" "sg_zabbix_proxy" {
  name   = "sg_zabbix-proxy"
  #vpc_id = aws_vpc.vpc.id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                         = "pakcer generated ami"
  instance_type               = "t3.small"
  #subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg_zabbix_proxy.id]
  key_name = "your_key"
  associate_public_ip_address = true

  tags = {
    Name = "Zabbix-proxy-TF-test2"
  }
}

output "id" {
  value = aws_instance.web.public_ip
}
