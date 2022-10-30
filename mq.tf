# mq.tf | Message Queue Configuration

// TODO: Mention explicitly that we'll setup CLUSTER_MULTI_AZ
resource "aws_mq_broker" "mq_broker" {
  broker_name        = "${var.app_name}-broker"
  engine_type        = "RabbitMQ"
  engine_version     = "3.9.16"
  host_instance_type = "mq.m5.large"
  deployment_mode    = "CLUSTER_MULTI_AZ"
  #   security_groups     = [aws_security_group.mq_security_group.id]
  #   subnet_ids          = [aws_subnet.authentication_1a.id, aws_subnet.authentication_1b.id]
  publicly_accessible = true

  user {
    username = var.aws_mq_username
    password = var.aws_mq_password
  }
  tags = {
    Name        = "${var.app_name}-broker"
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

