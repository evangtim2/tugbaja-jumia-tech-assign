#comput outputs
output "public_ip" {
  value       = aws_instance.jenkins_server.public_ip
  description = "Public IP of Jenkins server"
}

#Security outputs
output "sg_id" {
  description = "Security group ID"
  value       = aws_security_group.jenkins_sg.id
}

#VPC outputs
output "public_subnet_id" {
  value       = "aws_subnet.devops_public_subnet.id"
  description = "ID public subnet"
}

output "vpc_id" {
  description = "ID of VPC"
  value       = aws_vpc.devops_vpc.id
}

#DB outputs
output "subnet_group" {
  value = aws_db_subnet_group.main.name
}

output "db_instance_id" {
  value = aws_db_instance.postgresql.id
}

output "db_instance_address" {
  value = aws_db_instance.postgresql.address
}