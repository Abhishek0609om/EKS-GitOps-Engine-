resource "aws_ecr_repository" "app" {
  name                 = "phoenix-app"
  image_tag_mutability = "MUTABLE"

  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = {
    Environment = "production"
    Project     = "phoenix"
  }

}