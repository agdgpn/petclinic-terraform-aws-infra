
variable "instance_type" {
  default = "t3.medium"
  
}
variable "instance_type2" {
  default = "t3.micro"
}
variable "instance_type3" {
  default = "t3.small"
}
variable "environment" {
  default = "my-env"
}
variable "project" {
  default = "my-project"
}
# The private ec2 on the first AZ
variable "private_ec2_1_name_tag" {
  default = "Private-ec2-1"
}
# The private ec2 on the second AZ
variable "private_ec2_2_name_tag" {
  default = "Private-ec2-2"
}

# Ec2 instance lauched by auto scaling group on the public subnets
variable "asg_public_ec2_name_tag" {
  default = "asg-instance-pub-subnets"
}

# Key Pair - must be generated before
variable "key_pair_name" {
  default = "my-key-pair"
}

# Custom AMI owner
variable "custom_ami_owner" {
  default = "099720109477"
}

#Custom AMI value
variable "custom_ami_value" {
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"
}

#Custom AMI value2
variable "custom_ami_value2" {
  default = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"
}

