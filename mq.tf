# mq.tf | Message Queue Configuration

// TODO: Mention explicitly that we'll setup CLUSTER_MULTI_AZ
resource "aws_mq_broker" "mq_broker_1a" {
  broker_name         = "${var.app_name}-broker-1a"
  engine_type         = "RabbitMQ"
  engine_version      = "3.9.16"
  host_instance_type  = "mq.t3.micro"
  deployment_mode     = "SINGLE_INSTANCE"
  security_groups     = [aws_security_group.mq_security_group.id]
  subnet_ids          = [aws_subnet.private_1a.id]
  publicly_accessible = false

  user {
    username = var.aws_mq_username
    password = var.aws_mq_password
  }
  tags = {
    Name        = "${var.app_name}-broker-1a"
    Environment = var.app_environment
  }
}

resource "aws_mq_broker" "mq_broker_1b" {
  broker_name         = "${var.app_name}-broker-1b"
  engine_type         = "RabbitMQ"
  engine_version      = "3.9.16"
  host_instance_type  = "mq.t3.micro"
  deployment_mode     = "SINGLE_INSTANCE"
  security_groups     = [aws_security_group.mq_security_group.id]
  subnet_ids          = [aws_subnet.private_1b.id]
  publicly_accessible = false

  user {
    username = var.aws_mq_username
    password = var.aws_mq_password
  }
  tags = {
    Name        = "${var.app_name}-broker-1b"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "mq_security_group" {
  vpc_id = aws_vpc.aws_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-mq-sg"
    Environment = var.app_environment
  }
}

