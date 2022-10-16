# ecs-1b.tf | Elastic Container Service Cluster and Tasks Configuration for AZ 1b

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

resource "aws_ecs_task_definition" "aws_ecs_task_1b" {
  for_each = var.microservices
  family   = "${var.app_name}-task-${each.key}-1b"

  container_definitions = <<DEFINITION
    [
        {
            "name" : "${var.app_name}-${each.key}-1b",
            "image" : "${var.app_name}-ecr-${each.key}-latest",
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
                    "hostPort" : ${each.value.hostPort},
                    "containerPort" : ${each.value.containerPort}
                }
            ],
            "environment": ${jsonencode(var.microservices_env_config[each.key])},
            "cpu" : ${each.value.indivdualCpu},
            "memory" : ${each.value.individualMemory},
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

data "aws_ecs_task_definition" "main_1b" {
  for_each        = var.microservices
  task_definition = aws_ecs_task_definition.aws_ecs_task_1b[each.key].family
}

resource "aws_ecs_service" "aws_ecs_service_webserver_1b" {
  name                 = "${var.app_name}-ecs-service-webserver-1b"
  cluster              = aws_ecs_cluster.aws_ecs_1b["webserver"].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1b["webserver"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1b["webserver"].revision, data.aws_ecs_task_definition.main_1b["webserver"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.public_1b.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.external_alb_target_group.arn
    container_name   = "${var.app_name}-webserver-1b"
    container_port   = var.microservices["webserver"].containerPort
  }

  depends_on = [aws_lb_listener.external_listener]
}

resource "aws_ecs_service" "aws_ecs_service_users_1b" {
  name                 = "${var.app_name}-ecs-service-users-1b"
  cluster              = aws_ecs_cluster.aws_ecs_1b[var.microservices["users"].cluster].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1b["users"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1b["users"].revision, data.aws_ecs_task_definition.main_1b["users"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.private_1b.id]
    assign_public_ip = false
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.internal_alb_target_group.arn
    container_name   = "${var.app_name}-users-1b"
    container_port   = var.microservices["users"].containerPort
  }

  depends_on = [aws_lb_listener.internal_listener]
}

resource "aws_ecs_service" "aws_ecs_service_notifications_1b" {
  name                 = "${var.app_name}-ecs-service-notifications-1b"
  cluster              = aws_ecs_cluster.aws_ecs_1b[var.microservices["notifications"].cluster].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1b["notifications"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1b["notifications"].revision, data.aws_ecs_task_definition.main_1b["notifications"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.private_1b.id]
    assign_public_ip = false
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }
}

resource "aws_ecs_service" "aws_ecs_service_authentication_1b" {
  name                 = "${var.app_name}-ecs-service-authentication-1b"
  cluster              = aws_ecs_cluster.aws_ecs_1b[var.microservices["authentication"].cluster].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1b["authentication"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1b["authentication"].revision, data.aws_ecs_task_definition.main_1b["authentication"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.private_1b.id]
    assign_public_ip = false
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.internal_alb_target_group.arn
    container_name   = "${var.app_name}-authentication-1b"
    container_port   = var.microservices["authentication"].containerPort
  }

  depends_on = [aws_lb_listener.internal_listener]
}
