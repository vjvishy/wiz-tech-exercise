provider "aws" {
  region  = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "vpc-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnets_cidr_blocks, 0, var.private_subnet_count)
  public_subnets  = slice(var.public_subnets_cidr_blocks, 0, var.public_subnet_count)

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.resource_tags
}

module "db_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"

  name        = "db-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  description = "Security group for Database with TCP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  #ingress_cidr_blocks = module.vpc.public_subnets_cidr_blocks
  ingress_cidr_blocks = [var.vpc_cidr_block]
  
  ingress_with_cidr_blocks  = [
    {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.resource_tags
}

/*
module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"

  name        = "app-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  description = "Security group for App with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = module.vpc.private_subnets_cidr_blocks

  tags = var.resource_tags
}
*/

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws//modules/web"

  name        = "lb-sg-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  description = "Security group for load balancer with HTTP ports open within VPC"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = var.resource_tags
}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"

  key_name            = "mongodb"
  create_private_key  = true
}

module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.2"

  bucket = "s3-bucket-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  depends_on = [module.vpc, module.key_pair, module.s3-bucket]

  name                        = var.db_instance_name
  instance_type               = var.instance_type
  ami                         = var.mongodb_ami_id
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.db_security_group.security_group_id]
  associate_public_ip_address = true
  key_name                    = "mongodb"

  tags = var.resource_tags
}

/*
module "elb_http" {
  source  = "terraform-aws-modules/elb/aws"
  version = "4.0.1"

  # Ensure load balancer name is unique
  name = "lb-${random_string.lb_id.result}-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"

  internal = false

  security_groups = [module.lb_security_group.security_group_id]
  subnets         = module.vpc.public_subnets

  #number_of_instances = length(module.ec2_instance.id)
  number_of_instances = var.instance_count
  instances           = [module.ec2_instance.id]

  listener = [{
    instance_port     = "80"
    instance_protocol = "HTTP"
    lb_port           = "80"
    lb_protocol       = "HTTP"
  }]

  health_check = {
    target              = "HTTP:80/index.html"
    interval            = 10
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
  }

  tags = var.resource_tags
}
*/