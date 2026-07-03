resource "aws_route53_zone" "public_dns_zone" {
  count = var.enable_public_dns_zone ? 1 : 0
  name  = var.public_dns_zone_name
}
