# AWS docker image repository
resource "aws_ecr_repository" "sp_shiny" {
  name = "shiny-spatial"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }  
}

# # build an image locally
# resource "null_resource" "local_r_docker_build" {
#   depends_on = [aws_ecr_repository.r_docker]
#   provisioner "local-exec" {
#     command = <<EOF
#       cd ../docker/R
#       $(aws ecr get-login --registry-ids 364518226878  --no-include-email)
#       docker build -t ${var.project}-r .
#       docker tag ${var.project}-r:latest ${aws_ecr_repository.r_docker.repository_url}:latest
#       docker push ${aws_ecr_repository.r_docker.repository_url}
#     EOF
#   }
# }
