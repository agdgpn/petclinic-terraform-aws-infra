output "rds_sg" {
  value       = module.compute.rds_sg
}
output "public_subnets" {
  value       = module.compute.public_subnets
}

output "launch_template_instance" {
  value       = module.compute.launch_template_instance
}

output "private_ec2_eu-west-3a" {
  value       = module.compute.private_ec2_eu-west-3a
}

output "private_ec2_eu-west-3b" {
  value       = module.compute.private_ec2_eu-west-3b
}