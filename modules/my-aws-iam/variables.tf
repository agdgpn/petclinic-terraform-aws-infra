variable "EKSClusterPolicy_arn" {
  description = "EKS Cluster Policy ARN"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

variable "EKSServicePolicy_arn" {
  description = "EKS Service Policy ARN"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

variable "EKSWorkerNodePolicy_arn" {
  description = "EKS Worker Node Policy ARN"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

variable "EKS_CNI_Policy_arn" {
  description = "EKS CNI Policy ARN"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

variable "EC2ContainerRegistryReadOnly_arn" {
  description = "EKS CNI Policy ARN"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}




