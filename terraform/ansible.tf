# export Terraform variable values to an Ansible var_file
resource "local_file" "tf_ansible_vars_file" {
  content = <<-DOC
    # Ansible vars_file containing variable values from Terraform.

    remote_user: ${var.remote_user}
    ec2_dns: ${var.ec2_dns}
    git_token: ${var.git_token}
    s3_bucket: ${var.s3_bucket}
    ecr_repo_url: ${aws_ecr_repository.geoshiny.repository_url}
    shiny_tag: ${var.shiny_tag}
    dbuser: ${var.dbuser}
    dbpass: ${var.dbpass}
    dbname: ${var.dbname}
    dbhost: ${var.dbhost}
    rsuser: ${var.rsuser}
    rspass: ${var.rspass}
    region: ${var.region}
    google_api: ${var.google_api}

    DOC
  filename = "../ansible/ansible_vars_file.yml"
}

