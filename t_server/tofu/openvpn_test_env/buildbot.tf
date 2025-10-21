locals {
  buildbot_instances = {
    "buildbot2310" = {
      instance_type               = "t3a.large",
      ami                         = module.ami.ubuntu_2310_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.primary-vpc.primary_public_subnet_id,
      tags = { "Role" : "buildbot",
        "tostop" : "true",
        "Distro" : "Ubuntu",
      "Login" : "ubuntu" },
      volume_size = 120,
      volume_tags = { "Name" : "buildbot",
      "Role" : "buildbot", },
      vpc_security_group_ids = [
        module.primary-vpc-standard-sg.id,
        aws_security_group.buildmaster.id,
      ]
    },
    "docker_host_arm64" = {
      instance_type               = "m7g.large",
      ami                         = module.ami.ubuntu_2404_arm64_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.primary-vpc.primary_public_subnet_id,
      tags = { "Role" : "docker_host",
        "tostop" : "true",
        "Distro" : "Ubuntu",
      "Login" : "ubuntu" },
      volume_size = 120,
      volume_tags = { "Name" : "docker_host_arm64",
      "Role" : "docker_host", },
      vpc_security_group_ids = [
        module.primary-vpc-standard-sg.id,
        aws_security_group.docker_host.id,
      ]
    },
    "freebsd142" = {
      instance_type               = "t3a.large",
      ami                         = module.ami.freebsd_142_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.primary-vpc.primary_public_subnet_id,
      tags = { "Role" : "test",
        "tostop" : "true",
        "Distro" : "FreeBSD",
      "Login" : "ec2-user" },
      volume_size = 60,
      volume_tags = { "Name" : "freebsd142",
      "Role" : "test", },
      vpc_security_group_ids = [
        module.primary-vpc-standard-sg.id,
      ]
    },
  }
}

module "buildbot_instance" {
  for_each = local.buildbot_instances

  amount                      = var.enable_buildbot ? 1 : 0
  source                      = "github.com/Puppet-Finland/terraform-aws_instance_wrapper?ref=2.10.2"
  ami                         = each.value["ami"]
  associate_public_ip_address = each.value["associate_public_ip_address"]
  default_root_block_device   = [{ volume_size = each.value["volume_size"] }]
  deployment                  = var.deployment
  disable_api_termination     = true
  ebs_optimized               = true
  hostname                    = each.key
  hosted_zone_id              = var.enable_private_dns_zone ? aws_route53_zone.private_dns_zone[0].zone_id : ""
  install_puppet_agent        = false
  instance_type               = each.value["instance_type"]
  key_name                    = each.value["key_name"]
  region                      = var.region
  restart_on_instance_failure = false
  restart_on_system_failure   = false
  source_dest_check           = each.value["source_dest_check"]
  subnet_id                   = each.value["subnet_id"]
  tags                        = each.value["tags"]
  vpc_security_group_ids      = each.value["vpc_security_group_ids"]
  volume_tags                 = each.value["volume_tags"]
}
resource "aws_security_group" "buildmaster" {
  name        = "buildmaster"
  description = "Buildmaster"
  vpc_id      = module.primary-vpc.vpc_id

  tags = {
    Name = "buildmaster"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_buildbot_workers_to_buildmaster" {
  security_group_id            = aws_security_group.buildmaster.id
  referenced_security_group_id = aws_security_group.docker_host.id
  ip_protocol                  = "tcp"
  from_port                    = 9989
  to_port                      = 9989
}

resource "aws_vpc_security_group_ingress_rule" "allow_buildmaster_v4_vpn" {
  security_group_id = aws_security_group.buildmaster.id
  cidr_ipv4         = var.vpn_cidr_block
  ip_protocol       = "tcp"
  from_port         = 8010
  to_port           = 8010
}

resource "aws_vpc_security_group_ingress_rule" "allow_buildmaster_v4_ubuntu_2404_vpn" {
  security_group_id = aws_security_group.buildmaster.id
  cidr_ipv4         = var.ubuntu_2404_vpn_cidr_block
  ip_protocol       = "tcp"
  from_port         = 8010
  to_port           = 8010
}

resource "aws_vpc_security_group_ingress_rule" "allow_buildmaster_v4_windows_vpn" {
  security_group_id = aws_security_group.buildmaster.id
  cidr_ipv4         = var.windows_vpn_cidr_block
  ip_protocol       = "tcp"
  from_port         = 8010
  to_port           = 8010
}

resource "aws_security_group" "docker_host" {
  name        = "docker_host"
  description = "Allow access to the docker daemon"
  vpc_id      = module.primary-vpc.vpc_id

  tags = {
    Name = "buildmaster"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_buildmaster_to_docker_host" {
  security_group_id            = aws_security_group.docker_host.id
  referenced_security_group_id = aws_security_group.buildmaster.id
  ip_protocol                  = "tcp"
  from_port                    = 2375
  to_port                      = 2375
}
