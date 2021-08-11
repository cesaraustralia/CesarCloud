# create a VPC for cesar development
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "cesar-server"
  }
}

# internet gate way
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
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
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.zone

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
  description = "Allow SSH, HTTP, Shiny, RStudio and PostgreSQL connections"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ips
  }

  ingress {
    description = "Postgres"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.ssh_ips
  }

  ingress {
    description = "Shiny"
    from_port   = 3838
    to_port     = 3838
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RStudio"
    from_port   = 8787
    to_port     = 8787
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


# create a network interface with an ip in the subnet
resource "aws_network_interface" "net_interface" {
  subnet_id       = aws_subnet.subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.security.id]

  tags = {
    Name = "cesar-server"
  }
}

# use a manually created static ip address for the instance
data "aws_eip" "eip" {
  public_ip = var.static_ip
}

# associate elastic public addrass
resource "aws_eip_association" "eip_associate" {
  allocation_id = data.aws_eip.eip.id
  network_interface_id = aws_network_interface.net_interface.id
  allow_reassociation  = true
}

