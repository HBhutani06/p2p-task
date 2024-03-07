output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_network.id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public_subnet[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private_subnet[*].id
}

output "internet_gateway_id" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.internet_gateway.id
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT gateways"
  value       = aws_nat_gateway.nat_gateway[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of route tables associated with private subnets"
  value       = aws_route_table.private_route_table[*].id
}