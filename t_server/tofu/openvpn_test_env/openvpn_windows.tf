resource "aws_eip" "openvpn_windows" {
  instance = module.openvpn_instance["openvpn_windows"].id[0]
  domain   = "vpc"
}

resource "aws_route53_record" "openvpn_windows-a" {
  count   = var.enable_public_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = "openvpn-windows.vpn-foss.org"
  type    = "A"
  ttl     = 300
  records = [aws_eip.openvpn_windows.public_ip]
}

resource "aws_route53_record" "openvpn_windows-aaaa" {
  count   = var.enable_public_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.public_dns_zone[0].zone_id
  name    = "openvpn-windows.vpn-foss.org"
  type    = "AAAA"
  ttl     = 300
  records = [module.openvpn_instance["openvpn_windows"].ipv6_addresses[0][0]]
}

resource "aws_route" "openvpn_windows_return_traffic" {
  route_table_id         = module.primary-vpc.public_route_table_id
  destination_cidr_block = var.windows_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_windows"].primary_network_interface_id[0]
}

resource "aws_route" "openvpn_windows_return_traffic_private" {
  route_table_id         = module.primary-vpc.private_route_table_id
  destination_cidr_block = var.windows_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_windows"].primary_network_interface_id[0]
}
# OpenVPN server (Windows) return traffic in office VPC through the (iroute) OpenVPN client
resource "aws_route" "windows_openvpn_client_return_traffic" {
  route_table_id         = module.secondary-vpc.public_route_table_id
  destination_cidr_block = var.windows_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_client_windows"].primary_network_interface_id[0]
}

resource "aws_route" "windows_openvpn_client_return_traffic_private" {
  route_table_id         = module.secondary-vpc.private_route_table_id
  destination_cidr_block = var.windows_vpn_cidr_block
  network_interface_id   = module.openvpn_instance["openvpn_client_windows"].primary_network_interface_id[0]
}
