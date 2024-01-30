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
