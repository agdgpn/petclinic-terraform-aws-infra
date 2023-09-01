
##############
# VPC
##############
module "eks" {
  source = "../../modules/my-aws-eks"
  project                   = "${var.project}"

}

###########################################
# Subnets Groups
###########################################

# Default subnets group (used by rds)
resource "aws_db_subnet_group" "default" {
  name        = "${var.project}-${var.environment}-default-group"
  description = "${var.project}-${var.environment} default subnet group"
  subnet_ids  = ["${module.eks.public_subnets[0].id}", "${module.eks.public_subnets[1].id}"]
}

###########################################
# AWS RDS Instances
###########################################

//RDS INSTANCE Testing
resource "aws_db_instance" "testing-rds" {
  engine                 = "mysql"
  engine_version         = "${var.engine_version}"
  instance_class         = "db.t2.micro"
  allocated_storage      = 8
  storage_type           = "gp2"
  identifier             = "petclinic-testing-database"
  db_name                = "${var.db_name}"
  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  username               = "${var.username}"
  password               = "${var.password}"
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.eks.rds_sg.id]
  tags = {
    Name = "Petclinic TESTING RDS instance"
   }
}

//RDS INSTANCE Prod
resource "aws_db_instance" "prod-rds" {
  engine                 = "mysql"
  engine_version         = "${var.engine_version}"
  instance_class         = "db.t2.micro"
  allocated_storage      = 8
  storage_type           = "gp2"
  identifier             = "petclinic-prod-database"
  db_name                = "${var.db_name}"
  db_subnet_group_name   = "${aws_db_subnet_group.default.id}"
  username               = "${var.username}"
  password               = "${var.password}"
  parameter_group_name   = "default.mysql5.7"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.eks.rds_sg.id]
  tags = {
    Name = "Petclinic PROD RDS instance"
   }
}