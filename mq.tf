# mq.tf | Message Queue Configuration

resource "aws_mq_broker" "mq_broker" {
  for_each           = toset(var.availability_zones)
  broker_name        = "${var.app_name}-broker-${each.key}"
  engine_type        = "RabbitMQ"
  engine_version     = "3.9.16"
  host_instance_type = "mq.t3.micro"
  security_groups    = [aws_security_group.mq_security_group.id]

  user {
    username = var.aws_mq_username
    password = var.aws_mq_password
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

