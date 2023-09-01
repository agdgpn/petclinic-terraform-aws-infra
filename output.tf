output "master_instance_id" {
  description = "ID of the EC2 jenkins master"
  value       = module.main.launch_template_instance.id
}

output "jenkins_agent_a_private_ip" {
  description = "Private IP address of the EC2 jenkins agent eu-west-3a"
  value       = module.main.private_ec2_eu-west-3a.private_ip
}

output "jenkins_agent_b_private_ip" {
  description = "Private IP address of the EC2 jenkins agent eu-west-3b"
  value       = module.main.private_ec2_eu-west-3b.private_ip
}