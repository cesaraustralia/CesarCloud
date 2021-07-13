# # define variables
variable "static_ip" {
  type = "string"
}

# ips with access to the ssh to ec2
variable "ssh_ips" {
  type = "list"
}

# ssh key for accessing ec2
variable "ssh_key" {
  type = "string"
}