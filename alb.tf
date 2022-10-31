# alb.tf | Load Balancer Configuration

resource "aws_lb" "web_alb" {
  name               = "${var.app_name}-web-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.web_1a.id, aws_subnet.web_1b.id]
  security_groups    = [aws_security_group.web_alb_security_group.id]

  depends_on = [
    aws_subnet.web_1a, aws_subnet.web_1b
  ]
  tags = {
    Name        = "${var.app_name}-web-alb"
    Environment = var.app_environment
  }
}

resource "aws_lb" "gateway_alb" {
  name               = "${var.app_name}-gateway-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.authentication_1a.id, aws_subnet.authentication_1b.id]
  security_groups    = [aws_security_group.gateway_alb_security_group.id]

  depends_on = [
    aws_subnet.authentication_1a, aws_subnet.authentication_1b
  ]
  tags = {
    Name        = "${var.app_name}-gateway-alb"
    Environment = var.app_environment
  }
}

resource "aws_lb_target_group" "web_alb_target_group" {
  name        = "${var.app_name}-web-tg"
  port        = var.microservices["webserver"]["containerPort"]
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.aws_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300" // 5 minutes
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/api/healthcheck"
    unhealthy_threshold = "2"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "${var.app_name}-web-tg"
    Environment = var.app_environment
  }
}

resource "aws_lb_target_group" "gateway_alb_target_group" {
  name        = "${var.app_name}-gateway-tg"
  port        = var.microservices["gateway"]["containerPort"]
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.aws_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300" // 5 minutes
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/api/healthcheck"
    unhealthy_threshold = "2"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "${var.app_name}-gateway-tg"
    Environment = var.app_environment
  }
}

resource "aws_lb_listener" "external_listener" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_alb_target_group.id
  }
}

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.gateway_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_alb_target_group.id
  }
}
