# AWS docker image repository
resource "aws_ecr_repository" "geoshiny" {
  name                 = "shiny-spatial"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

# print ecr url
output "ecr_ulr" {
  description = "The ECR URL"
  value       = aws_ecr_repository.geoshiny.repository_url
}

# build an image locally
resource "null_resource" "local_geoshiny_build" {
  depends_on = [aws_ecr_repository.geoshiny]
  # depends_on = [terraform_template]
  provisioner "local-exec" {
    command = <<EOF
      #!/bin/bash
      # cd ../docker
      cd ~/Public
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.geoshiny.repository_url}
      docker build -t shiny-spatial .
      docker tag shiny-spatial:latest ${aws_ecr_repository.geoshiny.repository_url}:latest
      docker push ${aws_ecr_repository.geoshiny.repository_url}:latest
    EOF
  }
}
