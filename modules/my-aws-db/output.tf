
output "launch_template_instance" {
  value       = module.eks.launch_template_instance
}

output "private_ec2_eu-west-3a" {
  value       = module.eks.private_ec2_eu-west-3a
}

output "private_ec2_eu-west-3b" {
  value       = module.eks.private_ec2_eu-west-3b
}