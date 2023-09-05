
variable "project" {
  description = "Project Name"
  type        = string
  default     = "my-aws"
}
# Nodes instances types
variable "node_ec2_type_1" {
  description = "AWS EC2 Instance type"
  type        = string
  default     = "t3.micro"
}
variable "node_ec2_type_2" {
  description = "AWS EC2 Instance type"
  type        = string
  default     = "t3.medium"
}
variable "node_ec2_type_3" {
  description = "AWS EC2 Instance type"
  type        = string
  default     = "t3.large"
}
variable "node_desired_size" {
  description = "Node desired size"
  type        = number
  default     = 1
}
variable "node_min_size" {
  description = "Node max size"
  type        = number
  default     = 0
}
variable "node_max_size" {
  description = "Node max size"
  type        = number
  default     = 2
}
variable "spot_node_desired_size" {
  description = "Node desired size"
  type        = number
  default     = 2
}
variable "spot_node_min_size" {
  description = "Node max size"
  type        = number
  default     = 0
}
variable "spot_node_max_size" {
  description = "Node max size"
  type        = number
  default     = 2
}