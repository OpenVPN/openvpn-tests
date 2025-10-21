locals {
  otterwiki_instances = {
    "otterwiki" = {
      instance_type               = "t3.medium",
      ami                         = module.ami.ubuntu_2404_amd64_id
      associate_public_ip_address = true
      key_name                    = var.key_name
      source_dest_check           = false,
      subnet_id                   = module.primary-vpc.primary_public_subnet_id,
      tags = { "Role" : "otterwiki",
        "tostop" : "true",
        "Distro" : "Ubuntu",
      "Login" : "ubuntu" },
      volume_size = 40,
      volume_tags = { "Name" : "otterwiki",
      "Role" : "otterwiki", },
      vpc_security_group_ids = [
        module.primary-vpc-standard-sg.id,
        module.primary-vpc-webserver-public-sg.id,
        aws_security_group.webcache.id,
      ]
    },
  }
}

module "otterwiki_instance" {
  for_each = local.otterwiki_instances

  amount                      = var.enable_otterwiki ? 1 : 0
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

resource "aws_eip" "wiki" {
  count    = var.enable_otterwiki ? 1 : 0
  instance = module.otterwiki_instance["otterwiki"].id[0]
  domain   = "vpc"
}

resource "aws_route53_record" "wiki-a" {
  count   = alltrue([var.enable_otterwiki, var.enable_public_dns_zone]) ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = "wiki.vpn-foss.org"
  type    = "A"
  ttl     = 300
  records = [aws_eip.wiki[0].public_ip]
}

resource "aws_route53_record" "wiki-aaaa" {
  count   = alltrue([var.enable_otterwiki, var.enable_public_dns_zone]) ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = "wiki.vpn-foss.org"
  type    = "AAAA"
  ttl     = 300
  records = [module.otterwiki_instance["otterwiki"].ipv6_addresses[0][0]]
}
