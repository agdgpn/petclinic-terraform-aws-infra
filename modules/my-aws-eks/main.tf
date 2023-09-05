##############
# VPC
##############
module "compute" {
  source = "../../modules/my-aws-ec2"
  
  key_pair_name             = "datascientest_keypair"
  environment               = "jenkins-test"
  project                   = "petclinic"
  private_ec2_1_name_tag    = "jenkins-agent-a"
  private_ec2_2_name_tag    = "jenkins-agent-b"
  asg_public_ec2_name_tag   = "jenkins-controller"
  custom_ami_owner          =  "125040901676"
  custom_ami_value          =  "jenkins-controller*"
  custom_ami_value2          =  "jenkins-agent*"
}
##############
# IAM
##############
module "iam" {
  source = "../../modules/my-aws-iam"
}

# EKS Cluster resource
resource "aws_eks_cluster" "aws_eks" {
  name     = "${var.project}-cluster"
  role_arn = module.iam.cluster_role.arn
  vpc_config {
    subnet_ids = [module.compute.private_subnets[0].id, module.compute.private_subnets[1].id]
  }

  tags = {
    Name = "${var.project}_EKS_Cluster"
  }
}
# EKS Node group 
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "${var.project}-standard-node-group"
  node_role_arn   = module.iam.nodes_role.arn
  subnet_ids   = [module.compute.private_subnets[0].id, module.compute.private_subnets[1].id]
  instance_types = ["${var.node_ec2_type_2}"]

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }
  update_config {
    max_unavailable = 2
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    module.iam.worker_node_policy_att,
    module.iam.cni_policy_att,
    module.iam.container_readOnly_policy_att,
  ]
  labels = {
    Name = "Petclinic-cluster-node"
  }
}

# EKS Node group  with spots
resource "aws_eks_node_group" "spots_node" {
  cluster_name    = aws_eks_cluster.aws_eks.name
  node_group_name = "${var.project}-spot-group-name"
  node_role_arn   = module.iam.nodes_role.arn
  subnet_ids      = [module.compute.private_subnets[0].id, module.compute.private_subnets[1].id]
  instance_types = ["${var.node_ec2_type_2}"]
  capacity_type = "SPOT"
  scaling_config {
    desired_size = var.spot_node_desired_size
    max_size     = var.spot_node_max_size
    min_size     = var.spot_node_min_size
  }
   
  labels = {
    type_of_nodegroup = "spot_untainted"
  }
  depends_on = [
    module.iam.worker_node_policy_att,
    module.iam.cni_policy_att,
    module.iam.container_readOnly_policy_att,
  ]
}
