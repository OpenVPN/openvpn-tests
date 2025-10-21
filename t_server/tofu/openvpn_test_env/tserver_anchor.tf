resource "aws_instance" "tserver_anchor" {
  ami                         = module.ami.rocky_9_id
  associate_public_ip_address = true
  disable_api_termination     = true
  ebs_optimized               = true
  instance_type               = "t3.small"
  key_name                    = var.key_name
  source_dest_check           = false
  subnet_id                   = module.primary-vpc.primary_public_subnet_id
  tags                        = { "Name": "tserver-anchor",
                                  "Role" : "Static tserver OpenVPN client",
                                  "tostop" : "true",
                                  "Distro" : "Rocky",
                                  "Login" : "rocky" }
  # The user data for tserver is close enough for the anchor VM
  user_data                   = module.tserver_anchor_user_data.user_data 
  vpc_security_group_ids      = [ module.primary-vpc-standard-sg.id, ]

  root_block_device {
    volume_size = 15
    tags        = { "Name" : "tserver-anchor",
                    "Role" : "Static tserver OpenVPN client", }
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

resource "aws_route53_record" "tserver_anchor_private_ipv4" {
  count   = var.enable_private_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.private_dns_zone[0].zone_id
  name    = "${var.tserver_anchor_hostname}.${var.private_dns_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.tserver_anchor.private_ip]
}

resource "aws_route53_record" "tserver_anchor_ipv6" {
  count   = var.enable_private_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.private_dns_zone[0].zone_id
  name    = "${var.tserver_anchor_hostname}.${var.private_dns_zone_name}"
  type    = "AAAA"
  ttl     = 300
  records = aws_instance.tserver_anchor.ipv6_addresses
}
