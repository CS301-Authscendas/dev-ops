# security.tf | ACL & SG Configuration

resource "aws_security_group" "web_alb_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-web-alb"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "web_ecs_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.web_alb_security_group.id]
  }

  tags = {
    Name        = "${var.app_name}-web-ecs"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "authentication_alb_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-authentication-alb"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "authentication_ecs_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.authentication_alb_security_group.id]
  }

  tags = {
    Name        = "${var.app_name}-authentication-ecs"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "organization_alb_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-organization-alb"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "organization_ecs_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.organization_alb_security_group.id]
  }

  tags = {
    Name        = "${var.app_name}-organization-ecs"
    Environment = var.app_environment
  }
}
