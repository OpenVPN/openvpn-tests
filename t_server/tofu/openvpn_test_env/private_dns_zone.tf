resource "aws_route53_zone" "private_dns_zone" {
  count = var.enable_private_dns_zone ? 1 : 0
  name  = var.private_dns_zone_name

  vpc {
    vpc_id = module.primary-vpc.vpc_id
  }
}

# Ensure that VMs in this VPC are able to resolve names
resource "aws_vpc_dhcp_options" "resolve_private_dns" {
  count               = var.enable_private_dns_zone ? 1 : 0
  domain_name         = var.private_dns_zone_name
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "resolve_private_dns" {
  count           = var.enable_private_dns_zone ? 1 : 0
  vpc_id          = module.primary-vpc.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.resolve_private_dns[0].id
}
