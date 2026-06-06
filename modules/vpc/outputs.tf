output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.main.id
}

output "availability_zones" {
  description = "The availability zones in the region"
  value = data.aws_availability_zones.azs.names
}

output "public_subnet_id" {
  description = "The IDs of the public subnets"
  value = aws_subnet.public_subnet_1.id
}



output "private_app_subnet_ids" {
  description = "The IDs of the private application subnets"
  value = aws_subnet.private_app_subnet_1.id
}

output "private_db_subnet_ids" {
  description = "The IDs of the private database subnets"
  value = aws_subnet.private_db_subnet_1.id
}

output "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  value = aws_db_subnet_group.db_subnet_group.name
}