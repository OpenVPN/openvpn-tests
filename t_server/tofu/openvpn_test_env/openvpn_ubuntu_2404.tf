resource "aws_eip" "openvpn_ubuntu_2404" {
  instance = module.openvpn_instance["openvpn_ubuntu_2404"].id[0]
  domain   = "vpc"
}

resource "aws_route53_record" "openvpn_ubuntu_2404-a" {
  count   = var.enable_public_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = "openvpn_ubuntu_2404.${var.public_dns_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.openvpn_ubuntu_2404.public_ip]
}

resource "aws_route53_record" "openvpn_ubuntu_2404-aaaa" {
  count   = var.enable_public_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = "openvpn_ubuntu_2404.${var.public_dns_zone_name}"
  type    = "AAAA"
  ttl     = 300
  records = [module.openvpn_instance["openvpn_ubuntu_2404"].ipv6_addresses[0][0]]
}

# OpenVPN return traffic in main VPC through the OpenVPN server
resource "aws_route" "openvpn_ubuntu_2404_return_traffic" {
  route_table_id         = module.primary-vpc.public_route_table_id
  destination_cidr_block = var.ubuntu_2404_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_ubuntu_2404"].primary_network_interface_id[0]
}

resource "aws_route" "openvpn_ubuntu_2404_return_traffic_private" {
  route_table_id         = module.primary-vpc.private_route_table_id
  destination_cidr_block = var.ubuntu_2404_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_ubuntu_2404"].primary_network_interface_id[0]
}

# OpenVPN return traffic in office VPC through the (iroute) OpenVPN client
resource "aws_route" "openvpn_ubuntu_2404_client_return_traffic" {
  route_table_id         = module.secondary-vpc.public_route_table_id
  destination_cidr_block = var.ubuntu_2404_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_client_ubuntu_2404"].primary_network_interface_id[0]
}

resource "aws_route" "openvpn_ubuntu_2404_client_return_traffic_private" {
  route_table_id         = module.secondary-vpc.private_route_table_id
  destination_cidr_block = var.ubuntu_2404_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_client_ubuntu_2404"].primary_network_interface_id[0]
}
