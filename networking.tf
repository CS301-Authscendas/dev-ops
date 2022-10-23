# networking.tf | VPC and Subnet Configuration

resource "aws_vpc" "aws_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

resource "aws_internet_gateway" "aws_igw" {
  vpc_id = aws_vpc.aws_vpc.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}

# ==== CONFIGURATION FOR AVAILABILITY ZONE 1A ==== #
resource "aws_subnet" "web_1a" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.web_subnets_1a
  availability_zone = var.availability_zones[0]
  tags = {
    Name        = "${var.app_name}-public-subnet-1a"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "authentication_1a" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.authentication_subnets_1a
  availability_zone = var.availability_zones[0]
  tags = {
    Name        = "${var.app_name}-authentication-1a"
    Environment = var.app_environment
  }
}

# ==== CONFIGURATION FOR AVAILABILITY ZONE 1B ==== #
resource "aws_subnet" "web_1b" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.web_subnets_1b
  availability_zone = var.availability_zones[1]
  tags = {
    Name        = "${var.app_name}-web-1b"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "authentication_1b" {
  vpc_id            = aws_vpc.aws_vpc.id
  cidr_block        = var.authentication_subnets_1b
  availability_zone = var.availability_zones[1]
  tags = {
    Name        = "${var.app_name}-authentication-1b"
    Environment = var.app_environment
  }
}

# ==== CONFIGURATION FOR ROUTING TABLE ==== #
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.aws_vpc.id
  depends_on = [
    aws_internet_gateway.aws_igw
  ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }

  tags = {
    Name        = "${var.app_name}-routing-table-web"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "web_1a" {
  subnet_id      = aws_subnet.web_1a.id
  route_table_id = aws_route_table.web.id
}

resource "aws_route_table_association" "web_1b" {
  subnet_id      = aws_subnet.web_1b.id
  route_table_id = aws_route_table.web.id
}

# NOTE: Refer to https://stackoverflow.com/questions/61265108/aws-ecs-fargate-resourceinitializationerror-unable-to-pull-secrets-or-registry
# ==== CONFIGURATION FOR NAT GATEWAY ==== #
# resource "aws_eip" "aws_eip_1a" {
#   vpc = true
#   tags = {
#     Name = "${var.app_name}-eip-1a"
#   }
# }

# resource "aws_eip" "aws_eip_1b" {
#   vpc = true
#   tags = {
#     Name = "${var.app_name}-eip-1b"
#   }
# }

# resource "aws_nat_gateway" "aws_ngw_1a" {
#   allocation_id = aws_eip.aws_eip_1a.id
#   subnet_id     = aws_subnet.web_1a.id
#   depends_on    = [aws_internet_gateway.aws_igw, aws_eip.aws_eip_1a]
#   tags = {
#     Name = "${var.app_name}-ngw-1a"
#   }
# }

# resource "aws_nat_gateway" "aws_ngw_1b" {
#   allocation_id = aws_eip.aws_eip_1b.id
#   subnet_id     = aws_subnet.web_1b.id
#   depends_on    = [aws_internet_gateway.aws_igw, aws_eip.aws_eip_1b]
#   tags = {
#     Name = "${var.app_name}-ngw-1b"
#   }
# }

# ==== CONFIGURATION FOR PRIVATE ROUTE TABLE ==== #
resource "aws_route_table" "authentication" {
  vpc_id = aws_vpc.aws_vpc.id
  depends_on = [
    aws_internet_gateway.aws_igw
  ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_igw.id
  }

  tags = {
    Name        = "${var.app_name}-routing-table-authentication"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "authentication_1a" {
  subnet_id      = aws_subnet.authentication_1a.id
  route_table_id = aws_route_table.authentication.id
}

resource "aws_route_table_association" "authentication_1b" {
  subnet_id      = aws_subnet.authentication_1b.id
  route_table_id = aws_route_table.authentication.id
}
