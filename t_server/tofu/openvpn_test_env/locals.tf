locals {
  cn                                               = "tserver.${var.public_dns_zone_name}"
  tserver_anchor_fqdn                              = "${var.tserver_anchor_hostname}.${var.public_dns_zone_name}"
  tserver_client_fqdn                              = "${var.tserver_client_hostname}.${var.public_dns_zone_name}"
  tserver_rocky_9_amd64_fqdn                       = "${var.tserver_rocky_9_amd64_hostname}.${var.public_dns_zone_name}"
  tserver_rocky_9_amd64_private_fqdn               = "${var.tserver_rocky_9_amd64_hostname}.${var.private_dns_zone_name}"
  tserver_keydir                                   = "${var.tserver_data_dir}/keys"
  primary_vpc_id                                   = var.manage_vpc ? module.primary-vpc[0].vpc_id : var.external_primary_vpc_id
  primary_vpc_primary_public_subnet_id             = var.manage_vpc ? module.primary-vpc[0].primary_public_subnet_id : var.external_primary_vpc_primary_public_subnet_id
  primary_vpc_primary_public_subnet_route_table_id = var.manage_vpc ? module.primary-vpc[0].public_route_table_id : var.external_primary_vpc_primary_public_route_table_id
  primary_vpc_cidr_block                           = var.manage_vpc ? module.primary-vpc[0].cidr_block : data.aws_vpc.primary[0].cidr_block
  primary_vpc_ipv6_cidr_block                      = var.manage_vpc ? module.primary-vpc[0].ipv6_cidr_block : data.aws_vpc.primary[0].ipv6_cidr_block
}
