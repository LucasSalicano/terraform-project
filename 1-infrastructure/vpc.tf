provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {}
}

resource "aws_vpc" "production-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "production-vpc"
  }
}

variable "subnets" {
  description = "A list of subnets"
  type = list(object({
    cidr_block        = string
    availability_zone = string
    name              = string
    type              = string
  }))

  default = [
    {
      cidr_block        = var.public_subnet_1_cidr
      availability_zone = "us-east-1a"
      name              = "public-subnet-1"
      type              = "public"
    },
    {
      cidr_block        = var.public_subnet_2_cidr
      availability_zone = "us-east-1b"
      name              = "public-subnet-2"
      type              = "public"
    },
    {
      cidr_block        = var.public_subnet_3_cidr
      availability_zone = "us-east-1c"
      name              = "public-subnet-3"
      type              = "public"
    },
    {
      cidr_block        = var.private_subnet_1_cidr
      availability_zone = "us-east-1a"
      name              = "private-subnet-1"
      type              = "private"
    },
    {
      cidr_block        = var.private_subnet_2_cidr
      availability_zone = "us-east-1a"
      name              = "private-subnet-2"
      type              = "private"
    },
    {
      cidr_block        = var.private_subnet_3_cidr
      availability_zone = "us-east-1a"
      name              = "private-subnet-3"
      type              = "private"
    }
  ]
}

resource "aws_subnet" "subnet" {
  count             = length(var.subnets)
  vpc_id            = aws_vpc.production-vpc.id
  cidr_block        = var.subnets[count.index].cidr_block
  availability_zone = var.subnets[count.index].availability_zone

  tags = {
    Name = var.subnets[count.index].name
    Type = var.subnets[count.index].type
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table_association" "association" {
  count          = length(var.subnets)
  route_table_id = var.subnets[count.index].type == "public" ? aws_route_table.public-route-table.id : aws_route_table.private-route-table.id
  subnet_id      = aws_subnet.subnet[count.index].id

  depends_on = [aws_subnet.subnet]
}

resource "aw_eip" "elastic-ip-for-nat-gateway" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"

  tags = {
    Name = "production-eip"
  }
}

resource "aws_nat-gateway" "nat-gateway" {
  allocation_id = aws_eip.elastic-ip-for-nat-gateway.id
  subnet_id     = aws_subnet.subnet[0].id

  tags = {
    Name = "production-nat-gateway"
  }

  depends_on = [aws_eip.elastic-ip-for-nat-gateway]
}

resource "aws_route" "route-to-nat-gateway" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_nat_gateway.nat-gateway]
}

resource "aws_internet_gateway" "production-igw" {
  vpc_id = aws_vpc.production-vpc.id

  tags = {
    Name = "production-igw"
  }
}

resource "aws_route" "public-internet-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.production-igw.id
  destination_cidr_block = "0.0.0.0/0"

  depends_on = [aws_internet_gateway.production-igw]
}
