# ecs.tf | Elastic Container Service Cluster and Tasks Configuration

# Ubuntu 18.04 LTS (64-bit x86) - ami-0ee23bfc74a881de5
resource "aws_ecs_cluster" "aws-ecs-authentication" {
  name = "${var.app_name}-authentication"
}
