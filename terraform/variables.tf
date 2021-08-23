# # define variables
variable "static_ip" {
  type = string
  sensitive = true
}

# ips with access to the ssh to ec2
variable "ssh_ips" {
  type = list(string)
  sensitive = true
}

# ssh key for accessing ec2
variable "ssh_key" {
  type = string
  sensitive = true
}

# AWS region and availability zone
variable "region" {
  type = string
}
# availability zone
variable "zone" {
  type = string
}

# variables for the docker compose file
# shiny-spatial docker image tag
variable "shiny_tag" {
  type = string
}
# PostgreSQL database password
variable "dbuser" {
  type = string
  sensitive = true
}
variable "dbpass" {
  type = string
  sensitive = true
}
variable "rspass" {
  type = string
  sensitive = true
}
variable "dbname" {
  type = string
  sensitive = true
}

# s3 bucket name
variable "s3_bucket" {
  type = string
}

variable "git_token" {
  type = string
  sensitive = true
}
