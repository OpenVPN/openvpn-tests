locals {
  openvpn_instances = {
    "openvpn_rocky_9" = {
      instance_type               = "t3.small",
      ami                         = module.ami.rocky_9_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.primary-vpc.primary_public_subnet_id,
      tags = { "Role" : "OpenVPN server",
        "tostop" : "true",
        "Distro" : "Rocky",
      "Login" : "rocky" },
      volume_size = 15,
      volume_tags = { "Name" : "openvpn",
      "Role" : "OpenVPN server", },
      vpc_security_group_ids = [
        module.primary-vpc-standard-sg.id,
        aws_security_group.openvpn_server.id
      ]
    },
    "openvpn_windows" = {
      instance_type               = "t3.medium",
      ami                         = module.ami.windows_server_2025_base_id
      associate_public_ip_address = true
      key_name                    = "openvpn-foss-windows-rsa"
      source_dest_check           = false,
      subnet_id                   = module.primary-vpc.primary_public_subnet_id,
      tags = { "Role" : "OpenVPN server",
        "tostop" : "true",
        "Distro" : "Windows",
      "Login" : "administrator" },
      volume_size = 60,
      volume_tags = { "Name" : "openvpn_windows",
      "Role" : "OpenVPN server", },
      vpc_security_group_ids = [
        module.primary-vpc-standard-sg.id,
        aws_security_group.windows.id,
        aws_security_group.openvpn_server.id
      ]
    },
    "openvpn_ubuntu_2404" = {
      instance_type               = "t3.small",
      ami                         = module.ami.ubuntu_2404_amd64_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.primary-vpc.primary_public_subnet_id,
      tags = { "Role" : "OpenVPN server",
        "tostop" : "true",
        "Distro" : "Ubuntu",
      "Login" : "ubuntu" },
      volume_size = 15,
      volume_tags = { "Name" : "openvpn_ubuntu_2404",
      "Role" : "OpenVPN server", },
      vpc_security_group_ids = [
        module.primary-vpc-standard-sg.id,
        aws_security_group.openvpn_server.id
      ]
    },
    "openvpn_client" = {
      instance_type               = "t3.small",
      ami                         = module.ami.rocky_9_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.secondary-vpc.primary_public_subnet_id,
      tags = { "Role" : "OpenVPN client",
        "tostop" : "true",
        "Distro" : "Rocky",
      "Login" : "rocky" },
      volume_size = 15,
      volume_tags = { "Name" : "openvpn",
      "Role" : "OpenVPN client", },
      vpc_security_group_ids = [
        module.secondary-vpc-standard-sg.id
      ]
    },
    "openvpn_client_ubuntu_2404" = {
      instance_type               = "t3.small",
      ami                         = module.ami.rocky_9_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.secondary-vpc.primary_public_subnet_id,
      tags = { "Role" : "OpenVPN client",
        "tostop" : "true",
        "Distro" : "Rocky",
      "Login" : "rocky" },
      volume_size = 15,
      volume_tags = { "Name" : "openvpn",
      "Role" : "OpenVPN client", },
      vpc_security_group_ids = [
        module.secondary-vpc-standard-sg.id
      ]
    },
    "openvpn_client_windows" = {
      instance_type               = "t3.small",
      ami                         = module.ami.rocky_9_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.secondary-vpc.primary_public_subnet_id,
      tags = { "Role" : "OpenVPN client",
        "tostop" : "true",
        "Distro" : "Rocky",
      "Login" : "rocky" },
      volume_size = 15,
      volume_tags = { "Name" : "openvpn",
      "Role" : "OpenVPN client", },
      vpc_security_group_ids = [
        module.secondary-vpc-standard-sg.id
      ]
    },
    "office_server" = {
      instance_type               = "t3.small",
      ami                         = module.ami.rocky_9_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = true,
      subnet_id                   = module.secondary-vpc.primary_public_subnet_id,
      tags = { "Role" : "Connectivity test target",
        "tostop" : "true",
        "Distro" : "Rocky",
      "Login" : "rocky" },
      volume_size = 15,
      volume_tags = { "Name" : "openvpn",
      "Role" : "Connectivity test target", },
      vpc_security_group_ids = [
        module.secondary-vpc-standard-sg.id
      ]
    },
    "private_office_server" = {
      instance_type               = "t3.small",
      ami                         = module.ami.rocky_9_id
      associate_public_ip_address = false
      key_name                    = var.key_name
      source_dest_check           = true,
      subnet_id                   = module.secondary-vpc.primary_private_subnet_id,
      tags = { "Role" : "Connectivity test target",
        "tostop" : "true",
        "Distro" : "Rocky",
      "Login" : "rocky" },
      volume_size = 10,
      volume_tags = { "Name" : "openvpn",
      "Role" : "Connectivity test target", },
      vpc_security_group_ids = [
        module.secondary-vpc-standard-sg.id
      ]
    },
  }
}

module "openvpn_instance" {
  for_each = local.openvpn_instances

  amount                      = 1
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
