terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "cesar-test-bucket1"
    key    = "terraform-state"
    region = "ap-southeast-2"
  }
}

# configure the AWS Provider
# region code for Sydney Australia
provider "aws" {
  region = var.region
}


# add a Ubuntu 20.4 instance on a EC2
resource "aws_instance" "ec2" {
  ami               = "ami-0567f647e75c7bc05"
  instance_type     = "t2.medium"
  availability_zone = var.zone
  key_name          = var.ssh_key

  # setup the EBS volume
  root_block_device {
    delete_on_termination = false
    volume_size = 100
  }

  # depend of the docker images to be built first
  depends_on = [null_resource.local_geoshiny_build]

  # assign the plicies to this ec2
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  # connect instance to a defined network
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
              git clone https://github.com/cesaraustralia/daragrub.git /srv/shiny-server/Pestimator
              git clone https://github.com/cesaraustralia/CesarDatabase.git /srv/shiny-server/CesarDatabase
              git clone https://github.com/cesaraustralia/ausresistancemap.git /srv/shiny-server/AusResistanceMap

              # clone and build the docker containers
              git clone https://github.com/cesaraustralia/CesarCloud.git /home/ubuntu/CesarCloud
              aws ecr get-login-password --region ${var.region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.geoshiny.repository_url}
              cd /home/ubuntu/CesarCloud/docker
              # modify the docker compose file with terraform variables
              awk '{sub("dbuser","${var.dbuser}")}1' compose-temp.yml | \
                awk '{sub("dbpass","${var.dbpass}")}1' | \
                awk '{sub("shinyimage","${aws_ecr_repository.geoshiny.repository_url}:${var.shiny_tag}")}1' | \
                awk '{sub("rstudiopass","${var.rspass}")}1' > docker-compose.yml
              sudo docker-compose -f docker-compose.yml up -d

              # now create the environment file for shiny apps
              echo -e "POSTGRES_USER=${var.dbuser}" >> .Renviron
              echo -e "POSTGRES_PASSWORD=${var.dbpass}" >> .Renviron
              echo -e "POSTGRES_DB=postgres" >> .Renviron
              sudo docker cp .Renviron docker_shiny_1:/home/shiny
              rm .Renviron

              EOF

  tags = {
    Name = "cesar-server"
  }
}

# ebs_block_device { }

