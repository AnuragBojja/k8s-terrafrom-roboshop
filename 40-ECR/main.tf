resource "aws_ecr_repository" "main" {
  count = length(var.service)
  name                 = "${var.project_name}/${var.service[count.index]}"
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = false
  }
}