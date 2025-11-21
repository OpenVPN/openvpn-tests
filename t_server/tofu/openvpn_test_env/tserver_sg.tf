resource "aws_security_group" "tserver" {
  name        = "tserver"
  description = "Allow access to OpenVPN ports"
  vpc_id      = local.primary_vpc_id

  tags = {
    Name = "tserver"
  }
}

# tun-tcp-p2mp
resource "aws_vpc_security_group_ingress_rule" "tun_tcp_p2mp" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "tcp"
  from_port         = 51194
  to_port           = 51194
  description       = "tun-tcp-p2mp"
}

# tun-tcp-p2mp: IPv4 HTTP proxy (test 1b)
resource "aws_vpc_security_group_ingress_rule" "tun_tcp_p2mp_http_proxy_ipv4" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv4         = local.primary_vpc_cidr_block
  ip_protocol       = "tcp"
  from_port         = 3128
  to_port           = 3128
  description       = "tun-tcp-p2mp-http-proxy-ipv4"
}

# tun-tcp-p2mp: IPv6 HTTP proxy (test 1c)
resource "aws_vpc_security_group_ingress_rule" "tun_tcp_p2mp_http_proxy_ipv6" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "tcp"
  from_port         = 3128
  to_port           = 3128
  description       = "tun-tcp-p2mp-http-proxy-ipv6"
}

# tun-udp-p2mp
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_tcp" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv4         = local.primary_vpc_cidr_block
  ip_protocol       = "tcp"
  from_port         = 30002
  to_port           = 30002
  description       = "tun-udp-p2mp"
}

resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_udp_1" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv4         = local.primary_vpc_cidr_block
  ip_protocol       = "udp"
  from_port         = 30001
  to_port           = 30001
  description       = "tun-udp-p2mp"
}

resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_udp_2" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51194
  to_port           = 51194
  description       = "tun-udp-p2mp"
}

resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_udp_3" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 30002
  to_port           = 30003
  description       = "tun-udp-p2mp"
}

# tun-tcp-p2mp: SOCKS proxy with udp4 (test 2d)
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_socks_proxy_udp4" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv4         = local.primary_vpc_cidr_block
  ip_protocol       = "tcp"
  from_port         = 1080
  to_port           = 1080
  description       = "tun-udp-p2mp-socks-proxy-udp4"
}

# tun-tcp-p2mp: SOCKS proxy with udp6 (test 2e)
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_socks_proxy_udp6" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "tcp"
  from_port         = 1080
  to_port           = 1080
  description       = "tun-udp-p2mp-socks-proxy-udp6"
}

# tun-udp-p2mp-topology-subnet
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_topology_subnet" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51195
  to_port           = 51195
  description       = "tun-udp-p2mp-topology-subnet"
}

# tap-udp-p2mp
resource "aws_vpc_security_group_ingress_rule" "tap_udp_p2mp" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51196
  to_port           = 51196
  description       = "tap-udp-p2mp"
}

# tun-udp-p2mp-112-mask
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_112_mask" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51197
  to_port           = 51197
  description       = "tun-udp-p2mp-112-mask"
}

# tun-udp-p2mp-fragment
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_fragment" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51198
  to_port           = 51198
  description       = "tun-udp-p2mp-fragment"
}

# tun-udp-p2p: static key with IPv4 (test 8)
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2p_ipv4" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv4         = local.primary_vpc_cidr_block
  ip_protocol       = "udp"
  from_port         = 51204
  to_port           = 51204
  description       = "tun-udp-p2p-ipv4"
}

# tun-udp-p2p: static key with IPv6 (test 8a)
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2p_ipv6" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51204
  to_port           = 51204
  description       = "tun-udp-p2p-ipv6"
}

# tun-udp-p2mp-global-authpam
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_global_authpam" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51199
  to_port           = 51199
  description       = "tun-udp-p2mp-global-authpam"
}

# tun-udp-p2mp-hash-defscript
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2mp_hash_defscript" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51200
  to_port           = 51200
  description       = "tun-udp-p2mp-hash-defscript"
}

# tap-tcp-p2p
resource "aws_vpc_security_group_ingress_rule" "tap_tcp_p2p" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "tcp"
  from_port         = 51204
  to_port           = 51204
  description       = "tap-tcp-p2p"
}

# tun-udp-p2p-tls-sha256
resource "aws_vpc_security_group_ingress_rule" "tun_udp_p2p_tls_sha256" {
  security_group_id = aws_security_group.tserver.id
  cidr_ipv6         = local.primary_vpc_ipv6_cidr_block
  ip_protocol       = "udp"
  from_port         = 51201
  to_port           = 51201
  description       = "tun-udp-p2p-tls-sha256"
}
