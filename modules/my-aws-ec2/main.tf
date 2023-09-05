###########################################
# Datasource
###########################################

/* AMI standard UBUNTU utilise pour un ec2 standard */
data "aws_ami" "ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20230516"]
  }
}
/* AMI personalisé pour jenkins master (controller) */
data "aws_ami" "custom_ami" {
  most_recent = true
  owners      = ["${var.custom_ami_owner}"]
  filter {
    name = "name"
    values = ["${var.custom_ami_value}"]
  }
}
/* AMI personalisé pour jenkins Agent */
data "aws_ami" "custom_ami2" {
  most_recent = true
  owners      = ["${var.custom_ami_owner}"]
  filter {
    name = "name"
    values = ["${var.custom_ami_value2}"]
  }
}

##############
# VPC
##############
module "vpc" {
  source = "../../modules/my-aws-vpc"
}
/*
##############
# ACM CERT
##############
module "certificate" {
  source = "../../modules/my-aws-acm"
}
*/
###########################################
# Instances on private subnets
###########################################

# Instance on the first private subnet
resource "aws_instance" "private-ec2-1" {
  instance_type = var.instance_type2
  ami           = data.aws_ami.custom_ami2.id
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = ["${module.vpc.private_sg.id}"]
  #subnet_id              = aws_subnet.private_subnet[0].id
  subnet_id              = module.vpc.private_subnets[0].id
  user_data = "${file("${path.module}/../../scripts/ec2-user-data.sh")}"

  tags = {
    Name = "${var.project}-${var.private_ec2_1_name_tag}"
  }
}

# Instance on the second private subnet
resource "aws_instance" "private-ec2-2" {
  instance_type = var.instance_type2
  ami           = data.aws_ami.custom_ami2.id
  key_name               = "${var.key_pair_name}"
  vpc_security_group_ids = ["${module.vpc.private_sg.id}"]
  #subnet_id              = aws_subnet.private_subnet[1].id
  subnet_id              = module.vpc.private_subnets[1].id

  user_data = "${file("${path.module}/../../scripts/ec2-user-data.sh")}"

  tags = {
    Name = "${var.project}-${var.private_ec2_2_name_tag}"
  }
}

###########################################
# Launch templates
###########################################

# Launch template on a public subnets
resource "aws_launch_template" "my_lt" {
  name_prefix   = "${var.project}-${var.environment}-lt"
  instance_type = var.instance_type3
  image_id      = data.aws_ami.custom_ami.id
  key_name      = "${var.key_pair_name}"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = ["${module.vpc.public_sg.id}"]
  }
}

###########################################
# Application load balancer (ALB)
###########################################

# ALB on public subnets
resource "aws_lb" "my_lb" {
  name               = "${var.project}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  subnets         = [module.vpc.public_subnets[0].id, module.vpc.public_subnets[1].id]
  security_groups = [module.vpc.alb_sg.id]

  tags = {
    Environment = "${var.environment}"
    Project     = "${var.project}"
    Terraform   = "true"
  }
}

###########################################
# ALB target groups
###########################################

# Target group for jenkins App listening on port 9000
resource "aws_lb_target_group" "my_trg_group" {
  name_prefix = "jks-lb"
  port        = 9000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc.id
  target_type = "instance"

  health_check {
    path                = "/login"
    port                = 9000
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

###########################################
# ALB listeners
###########################################

# ALB  Simple listener for jenkins app target group
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_trg_group.arn
    type             = "forward"
  }
}

# ALB Listener, redirect http to https
/*
resource "aws_alb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.my_lb.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}*/
# ALB HTTPS Listener
/*
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${module.certificate.my_certificate.arn}"

  default_action {
    target_group_arn = aws_lb_target_group.my_trg_group.arn
    type             = "forward"
  }
}
*/

###########################################
# ALB Listener certificates
###########################################
/*
resource "aws_lb_listener_certificate" "my_lb_listener_certificate" {
  listener_arn    = "${aws_lb_listener.alb_https_listener.arn}"
  certificate_arn = "${module.certificate.my_certificate.arn}"
}
*/
###########################################
# ALB auto scaling group
###########################################

# Jenkins auto scaling group
resource "aws_autoscaling_group" "my_as_group" {
  name                = "${var.project}-${var.environment}-asg"
  max_size            = 1
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [module.vpc.public_subnets[0].id, module.vpc.public_subnets[1].id]
  launch_template {
    id      = aws_launch_template.my_lt.id
    version = aws_launch_template.my_lt.latest_version
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.asg_public_ec2_name_tag}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [load_balancers, target_group_arns]
  }
}

resource "aws_autoscaling_attachment" "my_as_att" {
  autoscaling_group_name = aws_autoscaling_group.my_as_group.name
  lb_target_group_arn    = aws_lb_target_group.my_trg_group.arn
}