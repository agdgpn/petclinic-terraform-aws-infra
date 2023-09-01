################################################################
# Module ROOT - Creation de l'infrastructure AWS
# Les modules my-aws-ec2, my-aws-db, my-aws-iam et my-aws-eks
# peuvent etre executee de maniere indépendante mais le module
# my-aws-eks a besoin des autorisation définis dans my-aws-iam
# pour fonctionner.
################################################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.2.0"
}
provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment = "Test"
      Owner       = "TFProviders"
      Project     = "Petclinic"
    }
  }
}

############################################################
# INSTANCE - Activer la creation de l'infra (reseau et ec2)
############################################################

/* Debut commentaire activation
module "main" {
  source = "./modules/my-aws-ec2"
  key_pair_name             = "datascientest_keypair"
  environment               = "jenkins-test"
  project                   = "petclinic"
  private_ec2_1_name_tag    = "jenkins-agent-a"
  private_ec2_2_name_tag    = "jenkins-agent-b"
  asg_public_ec2_name_tag   = "jenkins-controller"
  custom_ami_owner          =  "125040901676"
  custom_ami_value          =  "jenkins-controller*"
}
Fin commentaire activation */


#########################################
# Mode EKS - Lancer la création de l'EKS
#########################################

/* Debut commentaire activation
module "main" {
  source = "./modules/my-aws-eks"

  project = "petclinic"

}
Fin commentaire activation */


################################################
# RDS - Activer la creation des instances RDS
################################################
/* Debut commentaire activation */
module "main" {
  source = "./modules/my-aws-db"
  environment               = "mysql-test"
  project                   = "petclinic"
}
/* Fin commentaire activation */
