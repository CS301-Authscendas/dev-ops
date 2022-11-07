# security.tf | ACL & SG Configuration

resource "aws_security_group" "web_alb_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  // NOTE: Allow HTTP connection from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // NOTE: Allow HTTPs connection from the internet
  ingress {
    from_port   = 443
    to_port     = 443
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
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    // NOTE: Allow connection from web ALB only
    security_groups = [aws_security_group.web_alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-web-ecs"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "gateway_alb_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  // NOTE: Allow HTTP connection from the internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // NOTE: Allow HTTPs connection from the internet
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-gateway-alb"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "gateway_ecs_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    // NOTE: Allow connection from gateway ALB only
    security_groups = [aws_security_group.gateway_alb_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-gateway-ecs"
    Environment = var.app_environment
  }
}


resource "aws_security_group" "authentication_ecs_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    // NOTE: Allow connection from gateway ECS only
    security_groups = [aws_security_group.gateway_ecs_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-authentication-ecs"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "organization_ecs_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    // NOTE: Allow connection from gateway and authentication ecs
    security_groups = [
      aws_security_group.mq_security_group.id,
      aws_security_group.gateway_ecs_security_group.id,
      aws_security_group.authentication_ecs_security_group.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-organization-ecs"
    Environment = var.app_environment
  }
}
