# ecs.tf | Elastic Container Service Cluster and Tasks Configuration

resource "aws_ecs_cluster" "aws_ecs_1a" {
  for_each = toset(var.clusters)
  name     = "${var.app_name}-ecs-${each.key}-1a"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name        = "${var.app_name}-ecs-${each.key}-1a"
    Environment = var.app_environment
  }
}

resource "aws_ecs_cluster" "aws_ecs_1b" {
  for_each = toset(var.clusters)
  name     = "${var.app_name}-ecs-${each.key}-1b"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = {
    Name        = "${var.app_name}-ecs-${each.key}-1b"
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

resource "aws_ecs_task_definition" "aws_ecs_task_1a" {
  for_each = var.microservices
  family   = "${var.app_name}-task-${each.key}-1a"

  container_definitions = <<DEFINITION
    [
        {
            "name" : "${var.app_name}-${each.key}-1a",
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
    Name        = "${var.app_name}-ecs-td-${each.key}-1a"
    Environment = var.app_environment
  }
}

resource "aws_ecs_task_definition" "aws_ecs_task_1b" {
  for_each = var.microservices
  family   = "${var.app_name}-task-${each.key}-1b"

  container_definitions = <<DEFINITION
    [
        {
            "name" : "${var.app_name}-${each.key}-1b",
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
    Name        = "${var.app_name}-ecs-td-${each.key}-1b"
    Environment = var.app_environment
  }
}

# ==== CONFIGURATION FOR ECS PUBLIC SUBNET === #
data "aws_ecs_task_definition" "main_1a" {
  for_each        = var.microservices
  task_definition = aws_ecs_task_definition.aws_ecs_task_1a[each.key].family
}

resource "aws_ecs_service" "aws_ecs_service_public_1a" {
  name                 = "${var.app_name}-ecs-service-webserver-1a"
  cluster              = aws_ecs_cluster.aws_ecs_1a["webserver"].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1a["webserver"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1a["webserver"].revision, data.aws_ecs_task_definition.main_1a["webserver"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [var.public_subnets_1a]
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "${var.app_name}-webserver-1a"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.external_listener]
}

data "aws_ecs_task_definition" "main_1b" {
  for_each        = var.microservices
  task_definition = aws_ecs_task_definition.aws_ecs_task_1b[each.key].family
}

resource "aws_ecs_service" "aws_ecs_service_public_1b" {
  name                 = "${var.app_name}-ecs-service-webserver-1b"
  cluster              = aws_ecs_cluster.aws_ecs_1b["webserver"].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1b["webserver"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1b["webserver"].revision, data.aws_ecs_task_definition.main_1b["webserver"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [var.public_subnets_1a]
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    container_name   = "${var.app_name}-webserver-1a"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.external_listener]
}

# ==== CONFIGURATION FOR ECS PUBLIC SUBNET === #


