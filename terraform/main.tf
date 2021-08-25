terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "cesar-storage"
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
    volume_size = 50
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
              sudo apt install \
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
              git clone https://${var.git_token}@github.com/cesaraustralia/daragrub.git /srv/shiny-server/Pestimator
              git clone https://${var.git_token}@github.com/cesaraustralia/CesarDatabase.git /srv/shiny-server/CesarDatabase
              git clone https://${var.git_token}@github.com/cesaraustralia/ausresistancemap.git /srv/shiny-server/AusResistanceMap

              # clone and build the docker containers
              git clone https://${var.git_token}@github.com/cesaraustralia/CesarCloud.git /home/ubuntu/CesarCloud
              aws ecr get-login-password --region ${var.region} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.geoshiny.repository_url}
              cd /home/ubuntu/CesarCloud/docker
              # modify the docker compose file with terraform variables
              awk '{sub("dbuser","${var.dbuser}")}1' compose-temp.yml | \
                awk '{sub("dbpass","${var.dbpass}")}1' | \
                awk '{sub("dbname","${var.dbname}")}1' | \
                awk '{sub("shinyimage","${aws_ecr_repository.geoshiny.repository_url}:${var.shiny_tag}")}1' | \
                awk '{sub("rstudiopass","${var.rspass}")}1' > docker-compose.yml
              # now run the containers
              sudo docker-compose -f docker-compose.yml up -d

              # now create the environment file for shiny apps
              echo -e "POSTGRES_USER=${var.dbuser}" >> .Renviron
              echo -e "POSTGRES_PASSWORD=${var.dbpass}" >> .Renviron
              echo -e "POSTGRES_DB=${var.dbname}" >> .Renviron
              sudo docker cp .Renviron docker_shiny_1:/home/shiny
              rm .Renviron


              # recover the database backup from our storage
              mkdir -p /home/ubuntu/db_backup
              sudo chown ubuntu:ubuntu /home/ubuntu/db_backup/
              cd /home/ubuntu/db_backup
              aws s3 cp s3://${var.s3_bucket}/database-backups/pg_backup_latest.gz .
              gunzip < pg_backup_latest.gz | sudo docker exec -i docker_postgis_1 psql -U ${var.dbuser} -d ${var.dbname}
              rm /home/ubuntu/db_backup/*

              # set up a cron jobs to backup db every Sunday
              line='0 3 * * 0 sudo docker exec -t docker_postgis_1 pg_dumpall -c -U ${var.dbuser} | gzip > /home/ubuntu/db_backup/pg_backup_`date +"\%y-\%m-\%d_\%H_\%M_\%S"`.gz'
              (crontab -u root -l; echo "$line" ) | crontab -u root -
              line='5 3 * * 0 sudo docker exec -t docker_postgis_1 pg_dumpall -c -U ${var.dbuser} | gzip > /home/ubuntu/db_backup/pg_backup_latest.gz'
              (crontab -u root -l; echo "$line" ) | crontab -u root -
              line='10 3 * * 0 aws s3 sync /home/ubuntu/db_backup s3://${var.s3_bucket}/database-backups/ && rm /home/ubuntu/db_backup/*'
              (crontab -u root -l; echo "$line" ) | crontab -u root -

              EOF

  tags = {
    Name = "cesar-server"
  }
}

