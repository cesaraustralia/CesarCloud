# AWS docker image repository
resource "aws_ecr_repository" "sp_shiny" {
  name = "shiny-spatial"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }  
}

