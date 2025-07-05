terraform {
  required_version = "1.12.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.51"
    }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.name
  }

}

#インターネットゲートウェイ
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-igw"
  }
}

#Publicサブネット
resource "aws_subnet" "public" {
  for_each = { for idx, az in var.azs : idx => az }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-${each.key}}"
  }
}

#Privateサブネット
resource "aws_subnet" "private" {
  for_each = { for idx, az in var.azs : idx => az }

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[each.key]
  availability_zone = each.value
  tags = {
    Name = "${var.name}-private-${each.key}"
  }
}

# NAT Gateway 用の Elastic IP
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  vpc      = true
  tags     = { Name = "${var.name}-eip-${each.key}" }
}

#NATゲートウェイ
resource "aws_nat_gateway" "this" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-public-route-table"
  }
}

resource "aws_route" "public_access_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.name}-private-route-table"
  }
}

resource "aws_route" "private_access_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "" "name" {

}
