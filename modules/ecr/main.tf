resource "aws_ecr_repository" "my_ecr_repo" {
  name                  = var.ecr_name
  force_delete          = var.repository_force_delete
  image_tag_mutability  = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}