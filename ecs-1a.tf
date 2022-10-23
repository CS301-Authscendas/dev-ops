# ecs-1a.tf | Elastic Container Service Cluster and Tasks Configuration for AZ 1a

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

resource "aws_ecs_task_definition" "aws_ecs_task_1a" {
  for_each = var.microservices
  family   = "${var.app_name}-task-${each.key}-1a"

  container_definitions = <<DEFINITION
    [
        {
            "name" : "${var.app_name}-${each.key}-1a",
            "image" : "${aws_ecr_repository.aws_ecr[each.value.cluster].repository_url}/${var.app_name}-ecr-${each.key}-latest",
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
            "environment_files": [{
                "type" : "s3",
                "value" : "${aws_s3_bucket.s3_bucket_secrets.arn}/${each.key}/.env"
            }],
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
    Name        = "${var.app_name}-ecs-td-${each.key}-1a"
    Environment = var.app_environment
  }
}

data "aws_ecs_task_definition" "main_1a" {
  for_each        = var.microservices
  task_definition = aws_ecs_task_definition.aws_ecs_task_1a[each.key].family
}

resource "aws_ecs_service" "aws_ecs_service_webserver_1a" {
  name                 = "${var.app_name}-ecs-service-webserver-1a"
  cluster              = aws_ecs_cluster.aws_ecs_1a["webserver"].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1a["webserver"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1a["webserver"].revision, data.aws_ecs_task_definition.main_1a["webserver"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.web_1a.*.id
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web_alb_target_group.arn
    container_name   = "${var.app_name}-webserver-1a"
    container_port   = var.microservices["webserver"].containerPort
  }

  depends_on = [aws_lb_listener.external_listener]
}

resource "aws_ecs_service" "aws_ecs_service_users_1a" {
  name                 = "${var.app_name}-ecs-service-users-1a"
  cluster              = aws_ecs_cluster.aws_ecs_1a[var.microservices["users"].cluster].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1a["users"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1a["users"].revision, data.aws_ecs_task_definition.main_1a["users"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.authentication_1a.id]
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  depends_on = [aws_lb_listener.internal_listener]
}

resource "aws_ecs_service" "aws_ecs_service_notifications_1a" {
  name                 = "${var.app_name}-ecs-service-notifications-1a"
  cluster              = aws_ecs_cluster.aws_ecs_1a[var.microservices["notifications"].cluster].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1a["notifications"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1a["notifications"].revision, data.aws_ecs_task_definition.main_1a["notifications"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.authentication_1a.id]
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }
}

resource "aws_ecs_service" "aws_ecs_service_authentication_1a" {
  name                 = "${var.app_name}-ecs-service-authentication-1a"
  cluster              = aws_ecs_cluster.aws_ecs_1a[var.microservices["authentication"].cluster].id
  task_definition      = "${aws_ecs_task_definition.aws_ecs_task_1a["authentication"].family}:${max(aws_ecs_task_definition.aws_ecs_task_1a["authentication"].revision, data.aws_ecs_task_definition.main_1a["authentication"].revision)}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = [aws_subnet.authentication_1a.id]
    assign_public_ip = true
    security_groups = [
      aws_security_group.ecs_security_group.id,
      aws_security_group.alb_security_group.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.authentication_alb_target_group.arn
    container_name   = "${var.app_name}-authentication-1a"
    container_port   = var.microservices["authentication"].containerPort
  }

  depends_on = [aws_lb_listener.internal_listener]
}
