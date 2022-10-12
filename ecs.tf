# ecs.tf | Elastic Container Service Cluster and Tasks Configuration

resource "aws_ecs_cluster" "aws_ecs" {
  for_each = toset(var.clusters)
  name     = "${var.app_name}-ecs-${each.key}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name        = "${var.app_name}-ecs-${each.key}"
    Environment = var.app_environment
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "${var.app_name}-logs"

  tags = {
    Application = var.app_name
    Environment = var.app_environment
  }
}

resource "aws_ecs_task_definition" "aws_ecs_task" {
  for_each = var.microservices
  family   = "${var.app_name}-task-${each.key}"

  container_definitions = <<DEFINITION
    [
        {
            "name" : "${var.app_name}",
            "image" : "${var.app_name}-ecr-${each.key}:latest",
            "entryPoint" : [],
            "essential" : true,
            "logConfiguration" : {
                "logDriver" : "awslogs",
                "options" : {
                    "awslogs-group" : "${aws_cloudwatch_log_group.log_group.id}",
                    "awslogs-region" : "${var.aws_region}",
                    "awslogs-stream-prefix" : "${var.app_name}"
                }
            },
            "portMappings" : [
                {
                    "hostPort" : "${each.value.hostPort}"
                    "containerPort" : "${each.value.containerPort}",
                }
            ],
            "cpu" : "${each.value.indivdualCpu}",
            "memory" : "${each.value.indivdualCpu}",
            "networkMode" : "awsvpc"
        }
    ]
    DEFINITION

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = each.value.totalMemory
  cpu                      = each.value.totalCpu
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  tags = {
    Name        = "${var.app_name}-ecs-td-${each.key}"
    Environment = var.app_environment
  }
}
