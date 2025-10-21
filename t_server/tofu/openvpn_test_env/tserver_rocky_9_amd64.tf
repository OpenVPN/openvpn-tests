resource "aws_instance" "tserver_rocky_9_amd64" {
  ami                         = module.ami.rocky_9_id
  associate_public_ip_address = true
  disable_api_termination     = true
  ebs_optimized               = true
  instance_type               = "t3.small"
  key_name                    = var.key_name
  source_dest_check           = false
  subnet_id                   = module.primary-vpc.primary_public_subnet_id
  tags                        = { "Name": "tserver-rocky-9-amd64",
                                  "Role" : "tserver",
                                  "tostop" : "true",
                                  "Distro" : "Rocky",
                                  "Login" : "rocky" }
  user_data                   = module.tserver_rocky_9_amd64_user_data.user_data 
  vpc_security_group_ids      = [ module.primary-vpc-standard-sg.id,
                                  aws_security_group.tserver.id, ]

  root_block_device {
    volume_size = 15
    tags        = { "Name" : "tserver-rocky-9-amd64",
                    "Role" : "tserver", }
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

# Add default tserver DNS entry pointing to this tserver instance
resource "aws_route53_record" "tserver_cname" {
  count   = var.enable_private_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.private_dns_zone[0].zone_id
  name    = "tserver"
  type    = "CNAME"
  ttl     = 300
  records = ["${var.tserver_rocky_9_amd64_hostname}.${var.private_dns_zone_name}"]
}

# Add DNS entries for this specific tserver instaces
resource "aws_route53_record" "tserver_rocky_9_amd64_private_ipv4" {
  count   = var.enable_private_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.private_dns_zone[0].zone_id
  name    = "${var.tserver_rocky_9_amd64_hostname}.${var.private_dns_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.tserver_rocky_9_amd64.private_ip]
}

resource "aws_route53_record" "tserver_rocky_9_amd64_ipv6" {
  count   = var.enable_private_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.private_dns_zone[0].zone_id
  name    = "${var.tserver_rocky_9_amd64_hostname}.${var.private_dns_zone_name}"
  type    = "AAAA"
  ttl     = 300
  records = aws_instance.tserver_rocky_9_amd64.ipv6_addresses
}

resource "aws_eip" "tserver_rocky_9_amd64" {
  instance = aws_instance.tserver_rocky_9_amd64.id
  domain   = "vpc"
}

resource "aws_route53_record" "tserver_rocky_9_amd64-a" {
  count   = var.enable_public_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = local.tserver_rocky_9_amd64_fqdn
  type    = "A"
  ttl     = 300
  records = [aws_eip.tserver_rocky_9_amd64.public_ip]
}

resource "aws_route53_record" "tserver_rocky_9_amd64-aaaa" {
  count   = var.enable_public_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = local.tserver_rocky_9_amd64_fqdn
  type    = "AAAA"
  ttl     = 300
  records = [aws_instance.tserver_rocky_9_amd64.ipv6_addresses[0]]
}

# OpenVPN return traffic in main VPC through the OpenVPN server
resource "aws_route" "tserver_rocky_9_amd64_return_traffic" {
  route_table_id         = module.primary-vpc.public_route_table_id
  destination_cidr_block = var.tserver_rocky_9_amd64_vpn_cidr_block
  network_interface_id   = aws_instance.tserver_rocky_9_amd64.primary_network_interface_id
}

resource "aws_route" "tserver_rocky_9_amd64_return_traffic_private" {
  route_table_id         = module.primary-vpc.private_route_table_id
  destination_cidr_block = var.tserver_rocky_9_amd64_vpn_cidr_block
  network_interface_id   = aws_instance.tserver_rocky_9_amd64.primary_network_interface_id
}

# OpenVPN return traffic in office VPC through the (iroute) OpenVPN client
#resource "aws_route" "openvpn_client_return_traffic" {
#  route_table_id         = module.secondary-vpc.public_route_table_id
#  destination_cidr_block = var.rocky_9_test_vpn_cidr_block
#  network_interface_id   = module.openvpn_instance["openvpn_client"].primary_network_interface_id[0]
#}
#
#resource "aws_route" "openvpn_client_return_traffic_private" {
#  route_table_id         = module.secondary-vpc.private_route_table_id
#  destination_cidr_block = var.rocky_9_test_vpn_cidr_block
#  network_interface_id   = module.openvpn_instance["openvpn_client"].primary_network_interface_id[0]
#}
