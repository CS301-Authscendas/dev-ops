# ecr.tf | Elastic Container Repository

resource "aws_ecr_repository" "aws_ecr" {
  for_each     = toset(var.clusters)
  name         = "${var.app_name}-ecr-${each.key}"
  force_delete = true
  tags = {
    Name        = "${var.app_name}-ecr-${each.key}"
    Environment = var.app_environment
  }
}
