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


# add a Ubuntu 20.4 instance on a EC2
# t2.medium for the main server
resource "aws_instance" "ec2" {
  ami               = "ami-0567f647e75c7bc05"
  instance_type     = "t2.micro"
  availability_zone = "ap-southeast-2a"
  key_name          = "cesar-main-key"

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.net_interface.id
  }

  # allocation_id = aws_eip.eip.id

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
              sudo apt install awscli -y

              # clone and build the docker containers
              #git clone https://github.com/rvalavi/CesarCloud.git ~/CesarCloud

              # sudo docker-compose -f ~/CesarCloud/docker/setup-compose.yml 

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
#  }

