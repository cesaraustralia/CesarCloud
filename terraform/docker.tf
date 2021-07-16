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



# aws_ecr_repository.geoshiny.docker_image.URL

# provider "docker" {
#   source = "kreuzwerker/docker"
# }

# # build the docker image locally
# resource "docker_image" "geoshiny_build" {
#   depends_on = [aws_ecr_repository.geoshiny]
#   name = "goeshiny"
#   build {
#     path = "~/Public"
#     tag = ["shiny-spatial:1.0"]
#     force_remove = false
#     keep_locally = true
#     # build_arg = {

#     # }
#     label = {
#       Author : "Roozbeh Valavi" 
#       Email : "rvalavi@cesaraustralia.com"
#       Website : "https://cesaraustralia.com/"
#     }
#   }  
# }

