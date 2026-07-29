module "primary-vpc-standard-sg" {
  source                     = "github.com/Puppet-Finland/opentofu-sg-standard?ref=1.1.0"
  basename                   = var.deployment
  vpc_id                     = local.primary_vpc_id
  allow_ssh_cidr_blocks      = [local.primary_vpc_cidr_block]
  allow_ssh_ipv6_cidr_blocks = ["::1/128", local.primary_vpc_ipv6_cidr_block]
}

# Open SSH port to the Internet if we can't do provisioning using private IP addresses
resource "aws_security_group_rule" "allow_ssh_from_any_ipv4" {
  count             = var.provision_with_private_ip ? 0 : 1
  security_group_id = module.primary-vpc-standard-sg.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "IPv4 SSH from anywhere"
}

resource "aws_security_group_rule" "allow_ssh_from_any_ipv6" {
  count             = var.provision_with_private_ip ? 0 : 1
  security_group_id = module.primary-vpc-standard-sg.id
  type              = "ingress"
  ipv6_cidr_blocks  = ["::/0"]
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  description       = "IPv6 SSH from anywhere"
}

module "primary-vpc-webserver-public-sg" {
  source   = "github.com/Puppet-Finland/opentofu-sg-webserver?ref=1.0.0"
  basename = var.deployment
  vpc_id   = local.primary_vpc_id
  type     = "public"
}

resource "aws_security_group" "webcache" {
  name        = "${var.deployment}-webcache"
  description = "Allow access to TCP on ports 8080-8090"
  vpc_id      = local.primary_vpc_id

  tags = {
    Name = "${var.deployment}-webcache"
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
