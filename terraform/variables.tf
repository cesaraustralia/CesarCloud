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

variable "zone" {
  type = string
}

variable "account_id" {
  type = list(string)
}