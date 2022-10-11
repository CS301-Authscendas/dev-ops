# networking.tf | VPC and Subnet Configuration

resource "aws_vpc" "aws-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

resource "aws_internet_gateway" "aws-igw" {
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
}

# ==== CONFIGURATION FOR AVAILABILITY ZONE 1A ==== #

resource "aws_subnet" "public-1a" {
  vpc_id            = aws_vpc.aws-vpc.id
  cidr_block        = var.public_subnets_1a
  availability_zone = var.availability_zones[0]
  tags = {
    Name        = "${var.app_name}-public-subnet-1a"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "private-1a" {
  vpc_id            = aws_vpc.aws-vpc.id
  count             = length(var.private_subnets_1a)
  cidr_block        = element(var.private_subnets_1a, count.index)
  availability_zone = var.availability_zones[0]
  tags = {
    Name        = "${var.app_name}-private-subnet-1a-${var.services[count.index]}"
    Environment = var.app_environment
  }
}

# ==== CONFIGURATION FOR AVAILABILITY ZONE 1B ==== #

resource "aws_subnet" "public-1b" {
  vpc_id            = aws_vpc.aws-vpc.id
  cidr_block        = var.public_subnets_1b
  availability_zone = var.availability_zones[1]
  tags = {
    Name        = "${var.app_name}-public-subnet-1b"
    Environment = var.app_environment
  }
}

resource "aws_subnet" "private-1b" {
  vpc_id            = aws_vpc.aws-vpc.id
  count             = length(var.private_subnets_1b)
  cidr_block        = element(var.private_subnets_1b, count.index)
  availability_zone = var.availability_zones[1]
  tags = {
    Name        = "${var.app_name}-private-subnet-1b-${var.services[count.index]}"
    Environment = var.app_environment
  }
}

# ==== CONFIGURATION FOR ROUTING TABLE ==== #
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aws-vpc.id
  depends_on = [
    aws_internet_gateway.aws-igw
  ]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-igw.id
  }

  # TODO: Check if default local route is created
  tags = {
    Name        = "${var.app_name}-routing-table-public"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "public-1a" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-1b" {
  subnet_id      = aws_subnet.public-1b.id
  route_table_id = aws_route_table.public.id
}

# ==== CONFIGURATION FOR NAT GATEWAY ==== #
resource "aws_eip" "eip-1a" {
  vpc = true
  tags = {
    Name = "${var.app_name}-eip-1a"
  }
}

resource "aws_eip" "eip-1b" {
  vpc = true
  tags = {
    Name = "${var.app_name}-eip-1b"
  }
}

resource "aws_nat_gateway" "ngw-1a" {
  allocation_id = aws_eip.eip-1a.id
  subnet_id     = aws_subnet.public-1a.id
  tags = {
    Name = "${var.app_name}-ngw-1a"
  }
  depends_on = [aws_internet_gateway.aws-igw, aws_eip.eip-1a]
}

resource "aws_nat_gateway" "ngw-1b" {
  allocation_id = aws_eip.eip-1b.id
  subnet_id     = aws_subnet.public-1b.id
  tags = {
    Name = "${var.app_name}-ngw-1b"
  }
  depends_on = [aws_internet_gateway.aws-igw, aws_eip.eip-1b]
}

# ==== CONFIGURATION FOR PRIVATE ROUTE TABLE ==== #
resource "aws_route_table" "private-1a" {
  vpc_id = aws_vpc.aws-vpc.id
  depends_on = [
    aws_internet_gateway.aws-igw
  ]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw-1a.id
  }

  # TODO: Check if default local route is created
  tags = {
    Name        = "${var.app_name}-routing-table-private-1a"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "private-1a" {
  count          = length(var.private_subnets_1a)
  subnet_id      = element(aws_subnet.private-1a.*.id, count.index)
  route_table_id = aws_route_table.private-1a.id
}

resource "aws_route_table" "private-1b" {
  vpc_id = aws_vpc.aws-vpc.id
  depends_on = [
    aws_internet_gateway.aws-igw
  ]

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw-1b.id
  }

  # TODO: Check if default local route is created
  tags = {
    Name        = "${var.app_name}-routing-table-private-1b"
    Environment = var.app_environment
  }
}

resource "aws_route_table_association" "private-1b" {
  count          = length(var.private_subnets_1b)
  subnet_id      = element(aws_subnet.private-1b.*.id, count.index)
  route_table_id = aws_route_table.private-1b.id
}
