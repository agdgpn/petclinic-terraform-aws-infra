# VPC Resource
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.project}-${var.environment}-vpc"
    Environment = var.environment
  }
}

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}
###########################################
# Subnets
###########################################

# Public Subnets on each availability zone
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-${var.environment}-${element(local.availability_zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
  }
}

# Private Subnets on each availability zone
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project}-${var.environment}-${element(local.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
  }
}

###########################################
# Security Groups
###########################################

# Publics EC2 Security groups
resource "aws_security_group" "pub-ec2-sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-${var.environment}-Public-EC2-SG"
  description = "${var.project}-${var.environment} public ec2 security group"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"] # SSH from anywhere
  }

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8443
    to_port   = 8443
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags        = {
           Name = "${var.project}-${var.environment}-Public-EC2-SG"
  }
}

# Private EC2 Security groups
resource "aws_security_group" "priv-ec2-sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.project}-${var.environment}-Private-EC2-SG"
  description = "${var.project}-${var.environment} private ec2 security group"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # SSH within the VPC
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags        = {
           Name = "${var.project}-${var.environment}-Private-EC2-SG"
  }
}

# AWS ALB security group
resource "aws_security_group" "alb_sg" {
  name = "${var.project}-${var.environment}-ALB-SG"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-ALB-SG"
  }
}

# AWS RDS security group
resource "aws_security_group" "pub-rds-sg" {
  name        = "${var.project}-${var.environment}-RDS-SG"
  description = "Allow MySQL Port"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    description = "Allowing Connection Mysql clients"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-${var.environment}-RDS-SG"
  }
}

###########################################
# Route Tables
###########################################

# Route table to route traffic for Public Subnet
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project}-${var.environment}-Public-RT"
    Environment = "${var.environment}"
  }
}
# Routing table to route traffic for Private Subnet
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.project}-${var.environment}-Private-RT"
    Environment = "${var.environment}"
  }
}

###########################################
# Route
###########################################

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Route for NAT Gateway
resource "aws_route" "private_internet_gateway" {
  route_table_id         = aws_route_table.private-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}

###########################################
# Route Table Associations
###########################################

# Route table associations for both Public subnet
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}

# Route table associations for both Private subnet
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private-rt.id
}

###########################################
# Elastic IPs 
###########################################

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}

###########################################
# Gateways
###########################################

#Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name"        = "${var.project}-${var.environment}-IGW"
    "Environment" = var.environment
  }
}

# NAT Gateway1
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = {
    Name        = "${var.project}-${var.environment}-NATGW"
    Environment = "${var.environment}"
  }
}