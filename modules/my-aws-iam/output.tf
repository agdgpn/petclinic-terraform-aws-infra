
output "cluster_role" {
  value       = aws_iam_role.eks_cluster
}

output "nodes_role" {
  value       = aws_iam_role.eks_nodes
}

output "cluster_policy_att" {
  value       = aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
}

output "service_policy_att" {
  value       = aws_iam_role_policy_attachment.AmazonEKSServicePolicy
}

output "worker_node_policy_att" {
  value       = aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy
}

output "cni_policy_att" {
  value       = aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
}

output "container_readOnly_policy_att" {
  value       = aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly
}

output "ebs_driver_policy_att" {
  value       = aws_iam_role_policy_attachment.worknode-AmazonEBSCSIDriver
}