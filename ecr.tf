# ecr.tf | Elastic Container Repository

resource "aws_ecr_repository" "aws-ecr" {
  for_each = toset(var.clusters)
  name     = "${var.app_name}-ecr-${each.key}"
  tags = {
    Name        = "${var.app_name}-ecr-${each.key}"
    Environment = var.app_environment
  }
}
