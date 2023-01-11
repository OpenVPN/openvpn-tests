data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 3.11.0"

  name = "${var.name}-vpc"
  cidr = "${var.cidr_prefix}.0.0/16"

  azs            = data.aws_availability_zones.available.names
  public_subnets = ["${var.cidr_prefix}.0.0/20", "${var.cidr_prefix}.128.0/20"]
  public_subnet_ipv6_prefixes = [ 1, 128 ]

  enable_dns_hostnames            = false
  enable_ipv6                     = true
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false

  # placement group can only be destroyed once all
  # instances are terminated
  depends_on = [aws_placement_group.cluster]
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 4.8.0"

  name   = "AllowAll (${var.name})"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = [ "0.0.0.0/0" ]
  ingress_ipv6_cidr_blocks = [ "::/0" ]
  ingress_rules       = [ "all-all" ]
  egress_cidr_blocks = [ "0.0.0.0/0" ]
  egress_ipv6_cidr_blocks = [ "::/0" ]
  egress_rules       = [ "all-all" ]
}

resource "aws_key_pair" "test" {
  key_name   = "${var.name}-test"
  public_key = var.ssh_pub_key
}

resource "aws_placement_group" "cluster" {
  name     = var.name
  strategy = "cluster"
}
