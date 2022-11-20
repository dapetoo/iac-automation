# terraform {
#   backend "s3" {
#     bucket         = "dapteoo-terraform-bucket"
#     key            = "global/s3/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }

provider "aws" {
  region = var.region
}

# Get list of availability zones
data "aws_availability_zones" "available" {
  state = "available"
}


# Create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_support

  #     tags = merge(
  #     var.tags,
  #     {
  #       Name = format("VPC-%s", var.name)
  #     } 
  #   )
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = var.preferred_number_of_public_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("PublicSubnet-%s", count.index)
    }
  )
}

# Create public subnets
resource "aws_subnet" "private" {
  count                   = var.preferred_number_of_private_subnets == null ? length(data.aws_availability_zones.available.names) : var.preferred_number_of_private_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name = format("PrivateSubnet-%s", count.index)
    }
  )
}

resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [
    aws_internet_gateway.ig,
  ]

  tags = merge(
    var.tags,
    {
      Name = format("%s-EIP", var.name)
    }
  )
}
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.private.*.id, 0)
  depends_on = [
    aws_internet_gateway.ig
  ]

  tags = merge(
    var.tags,
    {
      Name = format("%s-NAT", var.name)
    }
  )
}
