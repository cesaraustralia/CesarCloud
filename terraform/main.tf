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
  region = var.region
}


# add a Ubuntu 20.4 instance on a EC2
# t2.medium for the main server
resource "aws_instance" "ec2" {
  ami               = "ami-0567f647e75c7bc05"
  instance_type     = "t2.micro"
  availability_zone = var.zone
  key_name          = var.ssh_key

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.net_interface.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install git -y

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
              sudo apt install docker-compose -y
              sudo apt install awscli -y

              # make shiny server directory and clone the apps
              mkdir -p /srv/shiny-server
              git clone https://github.com/cesaraustralia/daragrub.git /srv/shiny-server/daragrub

              # clone and build the docker containers
              git clone https://github.com/cesaraustralia/CesarCloud.git /home/ubuntu/CesarCloud
              aws ecr get-login-password --region ${var.region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.geoshiny.repository_url}
              awk 'NR==14{print "    image: ${aws_ecr_repository.geoshiny.repository_url}:latest"}1' compose-temp.yml > docker-compose.yml
              sudo docker-compose -f /home/ubuntu/CesarCloud/docker/docker-compose.yml up -d

              EOF

  tags = {
    Name = "cesar-server"
  }
}

# ebs_block_device { }

