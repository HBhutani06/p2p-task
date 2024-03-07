# get available AZs
data "aws_availability_zones" "available_azs" {}

# define VPC
resource "aws_vpc" "main_network" {
  cidr_block = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

# define ${var.az_names} private subnets (one for each AZ)
resource "aws_subnet" "private_subnet" {
  count                   = length(var.az_names)
  cidr_block              = cidrsubnet(aws_vpc.main_network.cidr_block, 8, count.index)
  availability_zone       = var.az_names[count.index]
  vpc_id                  = aws_vpc.main_network.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "${var.name_prefix}-private-subnet-${count.index}"
  }
}

# define ${var.az_names} public subnets (one for each AZ)
resource "aws_subnet" "public_subnet" {
  count                   = length(var.az_names)
  cidr_block              = cidrsubnet(aws_vpc.main_network.cidr_block, 8, length(var.az_names) + count.index)
  availability_zone       = var.az_names[count.index]
  vpc_id                  = aws_vpc.main_network.id
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-subnet-${count.index}"
  }
}

# define IGW
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.main_network.id}"
  tags = {
    Name = "${var.name_prefix}-igw"
  }
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.main_network.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.internet_gateway.id}"
}

# define NAT gateway for each private subnet
resource "aws_eip" "nat_gateway_eip" {
  count      = length(var.az_names)
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "${var.name_prefix}-nat-gateway-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.az_names)
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.nat_gateway_eip.*.id, count.index)
  tags = {
    Name = "${var.name_prefix}-nat-gateway-${count.index}"
  }
}

# define route table for each private subnet
resource "aws_route_table" "private_route_table" {
  count  = length(var.az_names)
  vpc_id = aws_vpc.main_network.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  }

  tags = {
    Name = "${var.name_prefix}-nat-gateway-route-table-${count.index}"
  }
}
# associate route tables with private subnets
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.az_names)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.private_route_table.*.id, count.index)
}