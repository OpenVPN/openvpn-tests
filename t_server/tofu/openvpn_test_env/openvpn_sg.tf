resource "aws_security_group" "openvpn_server" {
  name        = "openvpn-server"
  description = "Allow access to UDP port 1194"
  vpc_id      = module.primary-vpc.vpc_id

  tags = {
    Name = "openvpn-server"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_openvpn_server_v4" {
  security_group_id = aws_security_group.openvpn_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "udp"
  from_port         = 1194
  to_port           = 1194
}

resource "aws_vpc_security_group_ingress_rule" "allow_openvpn_server_v6" {
  security_group_id = aws_security_group.openvpn_server.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "udp"
  from_port         = 1194
  to_port           = 1194
}
