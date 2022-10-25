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
  security_groups    = [aws_security_group.authentication_alb_security_group.id]

  depends_on = [
    aws_subnet.authentication_1a, aws_subnet.authentication_1b
  ]
  tags = {
    Name        = "${var.app_name}-gateway-alb"
    Environment = var.app_environment
  }
}

resource "aws_lb_target_group" "web_alb_target_group" {
  name        = "${var.app_name}-external-tg"
  port        = 3000
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
    Name        = "${var.app_name}-lb-web-tg"
    Environment = var.app_environment
  }
}

resource "aws_lb_target_group" "gateway_alb_target_group" {
  name        = "${var.app_name}-internal-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.aws_vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300" // 5 minutes
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/healthcheck"
    unhealthy_threshold = "2"
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name        = "${var.app_name}-lb-gateway-tg"
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

  #   default_action {
  # type = "redirect"

  # redirect {
  #   port        = "443"
  #   protocol    = "HTTPS"
  #   status_code = "HTTP_301"
  # }
  #   }
}

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.gateway_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_alb_target_group.id
  }

  #   default_action {
  # type = "redirect"

  # redirect {
  #   port        = "443"
  #   protocol    = "HTTPS"
  #   status_code = "HTTP_301"
  # }
  #   }
}

# resource "aws_lb_listener" "external-listener-https" {
#   load_balancer_arn = aws_lb.web_alb.arn
#   port              = "443"
#   protocol          = "HTTPS"

#   ssl_policy      = "ELBSecurityPolicy-2016-08"
#   certificate_arn = "<certificate-arn>"

#   default_action {
#     target_group_arn = aws_lb_target_group.target_group.id
#     type             = "forward"
#   }
# }
