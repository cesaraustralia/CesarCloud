# AWS docker image repository
resource "aws_ecr_repository" "geoshiny" {
  name                 = "shiny-spatial"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

output "ecr_ulr" {
  description = "The ECR URL"
  value = aws_ecr_repository.geoshiny.repository_url
}

# build an image locally
resource "null_resource" "local_geoshiny_build" {
  depends_on = [aws_ecr_repository.geoshiny]
  provisioner "local-exec" {
    command = <<EOF
      #!/bin/bash
      cd ../docker
      aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.geoshiny.repository_url}
      docker build -t shiny-spatial .
      docker tag shiny-spatial:latest ${aws_ecr_repository.geoshiny.repository_url}:latest
      docker push ${aws_ecr_repository.geoshiny.repository_url}:latest
    EOF
  }
}


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

