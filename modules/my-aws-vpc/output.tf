output "vpc" {
  value       = aws_vpc.vpc
}

output "public_subnets" {
  value       = aws_subnet.public_subnet
}

output "private_subnets" {
  value       = aws_subnet.private_subnet
}
output "public_sg" {
  value       = aws_security_group.pub-ec2-sg
}

output "private_sg" {
  value       = aws_security_group.priv-ec2-sg
}

output "alb_sg" {
  value       = aws_security_group.alb_sg
}

output "rds_sg" {
  value       = aws_security_group.pub-rds-sg
}