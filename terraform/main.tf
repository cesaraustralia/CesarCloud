terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# configure the AWS Provider
# region code for Sydney Australia
provider "aws" {
  region = "ap-southeast-2"
}

# create a VPC for cesar development
resource "aws_vpc" "main-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "cesar-development"
  }
}

# create a subnet for the sever
# managing IPs and networking 
resource "aws_subnet" "main-subnet" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "cesar-subnet"
  }
}

# add a Ubuntu 20.4 instance on a EC2
resource "aws_instance" "main-server" {
  ami           = "ami-0567f647e75c7bc05"
  instance_type = "t2.micro"

  tags = {
    Name = "ubuntu-server"
  }
}
