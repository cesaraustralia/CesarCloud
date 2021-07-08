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
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "cesar-server"
  }
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  # tags = {
  #   Name = "cesar-server"
  # }
}


resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

   route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "cesar-server"
  }
}


# create a subnet for the sever
# managing IPs and networking 
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"

  tags = {
    Name = "cesar-server"
  }
}


# reoute table association
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

# create security group and ploicies
resource "aws_security_group" "security" {
  name        = "allow_connection"
  description = "Allow SSH, HTTP and Postgres connections"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # cesar ip: 1.136.104.172
  # home ip:  141.168.90.188
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["1.136.104.172","141.168.90.188"]
  }

  ingress {
    description = "Shiny"
    from_port   = 3838
    to_port     = 3838
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cesar-server"
  }
}

# Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "net_interface" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.security.id]

}

# Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.net_interface.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}


# print out the public ip of the server
output "server_public_ip" {
  value = aws_eip.one.public_ip

}

# add a Ubuntu 20.4 instance on a EC2
# t2.medium for the main server
resource "aws_instance" "ec2" {
  ami           = "ami-0567f647e75c7bc05"
  instance_type = "t2.micro"
  availability_zone = "ap-southeast-2a"
  key_name = "cesar-main-key"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.net_interface.id
    
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install git -y

              sudo mkdir -p /srv/shiny-server
              git clone https://github.com/cesaraustralia/daragrub.git /srv/shiny-server/daragrub

              # installing docker in the instance
              sudo apt-get install \
                apt-transport-https \
                ca-certificates \
                curl \
                gnupg \
                lsb-release
              
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

              echo \
                "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
                $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
              
              sudo apt update -y
              sudo apt install docker-ce docker-ce-cli containerd.io -y
              sudo apt install docker.io -y

              # sudo docker run rocker/shiny:latest

              EOF

  tags = {
    Name = "cesar-server"
  }
}

# ebs_block_device {
#           + delete_on_termination = (known after apply)
#           + device_name           = (known after apply)
#           + encrypted             = (known after apply)
#           + iops                  = (known after apply)
#           + kms_key_id            = (known after apply)
#           + snapshot_id           = (known after apply)
#           + tags                  = (known after apply)
#           + throughput            = (known after apply)
#           + volume_id             = (known after apply)
#           + volume_size           = (known after apply)
#           + volume_type           = (known after apply)
#         }

