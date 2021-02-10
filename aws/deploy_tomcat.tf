provider "aws" {
  region="ap-south-1"
  access_key = var.access
  secret_key = var.secret
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("pub_key.pub")
}

resource "aws_vpc" "main" {
    cidr_block       = var.main_vpc_cidr
    instance_tenancy = "default"
    enable_dns_support = true
    enable_dns_hostnames = true
  }

 resource "aws_subnet" "subnet1" {
   vpc_id     = aws_vpc.main.id
   cidr_block = "10.0.1.0/24"
   availability_zone = "ap-south-1"
  }


resource "aws_instance" "Tomcat-Server" {
    ami = "ami-08e0ca9924195beba"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.bastion-sg.name]
    associate_public_ip_address = true
    tags = {
        Name = "Tomcat-Server"
    }
    key_name = aws_key_pair.my_key.key_name
    user_data = data.template_file.asg_init.rendered
    provisioner "file" {
      source      = "MusicStore.war"
      destination = "/tmp/MusicStore.war"
      connection {
        type     = "ssh"
        user     = "ec2-user"
        host     = self.public_ip
        private_key = file("pri_key.ppk")
      }
    }
}

  resource "aws_security_group" "bastion-sg" {
  name   = "bastion-security-group"
  vpc_id = "aws_vpc.main.id"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
} 


output "aws_link" {
  value=format("Access the AWS hosted app from here: http://%s%s", aws_instance.Tomcat-Server.public_dns, ":8080/MusicStore")
}
data "template_file" "asg_init" {
  template = file("${path.module}/userdata.tpl")
}
variable "access" {
  type = string
}
variable "secret" {
  type = string
}

variable "main_vpc_cidr" {
    description = "CIDR of the VPC"
    default = "10.0.0.0/16"
}
