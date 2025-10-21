module "primary-vpc-standard-sg" {
  source                     = "github.com/Puppet-Finland/opentofu-sg-standard?ref=1.1.0"
  basename                   = "production"
  vpc_id                     = module.primary-vpc.vpc_id
  allow_ssh_cidr_blocks      = [var.vpn_cidr_block, module.primary-vpc.cidr_block]
  allow_ssh_ipv6_cidr_blocks = ["::1/128", module.primary-vpc.ipv6_cidr_block]
}

module "primary-vpc-webserver-public-sg" {
  source   = "github.com/Puppet-Finland/opentofu-sg-webserver?ref=1.0.0"
  basename = "production"
  vpc_id   = module.primary-vpc.vpc_id
  type     = "public"
}

module "secondary-vpc-standard-sg" {
  source                     = "github.com/Puppet-Finland/opentofu-sg-standard?ref=1.1.0"
  basename                   = "office"
  vpc_id                     = module.secondary-vpc.vpc_id
  allow_ssh_cidr_blocks      = [var.vpn_cidr_block, module.secondary-vpc.cidr_block]
  allow_ssh_ipv6_cidr_blocks = ["::1/128", module.secondary-vpc.ipv6_cidr_block]
}

resource "aws_security_group" "webcache" {
  name        = "webcache"
  description = "Allow access to TCP on ports 8080-8090"
  vpc_id      = module.primary-vpc.vpc_id

  tags = {
    Name = "webcache"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_webcache_v4" {
  security_group_id = aws_security_group.webcache.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8090
}

resource "aws_vpc_security_group_ingress_rule" "allow_webcache_v6" {
  security_group_id = aws_security_group.webcache.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8090
}

resource "aws_security_group" "windows" {
  name        = "windows"
  description = "Allow access to Windows systems"
  vpc_id      = module.primary-vpc.vpc_id

  tags = {
    Name = "windows"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_rdp_v4_vpn" {
  security_group_id = aws_security_group.windows.id
  cidr_ipv4         = var.vpn_cidr_block
  ip_protocol       = "tcp"
  from_port         = 3389
  to_port           = 3389
}

resource "aws_vpc_security_group_ingress_rule" "allow_psrp_v4_vpn" {
  security_group_id = aws_security_group.windows.id
  cidr_ipv4         = var.vpn_cidr_block
  ip_protocol       = "tcp"
  from_port         = 5985
  to_port           = 5986
}
