
output "launch_template_instance" {
  value       = aws_launch_template.my_lt
}

output "private_ec2_eu-west-3a" {
  value       = aws_instance.private-ec2-1
}

output "private_ec2_eu-west-3b" {
  value       = aws_instance.private-ec2-2
}

# Forward VPC outputs

output "public_subnets" {
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  value       = module.vpc.private_subnets
}

output "public_sg" {
  value       = module.vpc.public_sg
}

output "private_sg" {
  value       = module.vpc.private_sg
}

output "alb_sg" {
  value       = module.vpc.alb_sg
}

output "rds_sg" {
  value       = module.vpc.rds_sg
}