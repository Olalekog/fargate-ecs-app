resource "aws_ecr_repository" "this" {
  count                = var.create_repository ? 1 : 0
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = var.repository_name
  }
}

data "aws_ecr_repository" "existing" {
  count = var.create_repository ? 0 : 1
  name  = var.repository_name
}
