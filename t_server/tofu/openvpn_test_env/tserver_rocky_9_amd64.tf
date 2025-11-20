resource "aws_instance" "tserver_rocky_9_amd64" {
  ami                         = module.ami.rocky_9_id
  associate_public_ip_address = true
  disable_api_termination     = true
  ebs_optimized               = true
  instance_type               = "t3.small"
  key_name                    = var.key_name
  source_dest_check           = false
  subnet_id                   = local.primary_vpc_primary_public_subnet_id
  tags                        = { "Name": "tserver-rocky-9-amd64",
                                  "Role" : "tserver",
                                  "tostop" : "true",
                                  "Distro" : "Rocky",
                                  "Login" : "rocky" }
  user_data                   = module.tserver_rocky_9_amd64_user_data.user_data 
  vpc_security_group_ids      = [ module.primary-vpc-standard-sg.id,
                                  aws_security_group.tserver.id, ]

  # Copy OpenVPN certificates and keys. This needs to be done using a
  # provisioner as the content will not fit into the userdata.
  connection {
    type        = "ssh"
    user        = "rocky"
    host        = var.provision_with_private_ip ? self.private_ip : self.public_ip
    private_key = file(var.tserver_provisioning_ssh_private_key)
  }

  provisioner "remote-exec" {
    inline = ["sudo mkdir -p ${local.tserver_keydir}",
              "sudo chown -R ${var.rocky_9_default_user}:${var.rocky_9_default_group} ${var.tserver_data_dir}"]
  }

  provisioner "file" {
    content     = module.pki.ca_cert
    destination = "${local.tserver_keydir}/ca.crt"
  }

  provisioner "file" {
    content     = module.pki.server_cert
    destination = "${local.tserver_keydir}/server.crt"
  }

  provisioner "file" {
    content     = module.pki.server_key
    destination = "${local.tserver_keydir}/server.key"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-anchor"]["cert"]
    destination = "${local.tserver_keydir}/anchor.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-22"]["cert"]
    destination = "${local.tserver_keydir}/client-22.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-23"]["cert"]
    destination = "${local.tserver_keydir}/client-23.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-24"]["cert"]
    destination = "${local.tserver_keydir}/client-24.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-25"]["cert"]
    destination = "${local.tserver_keydir}/client-25.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-26"]["cert"]
    destination = "${local.tserver_keydir}/client-26.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-27"]["cert"]
    destination = "${local.tserver_keydir}/client-27.crt"
  }

  provisioner "remote-exec" {
    inline = ["sudo chown -R ${var.rocky_9_default_user}:${var.rocky_9_default_group} ${var.tserver_data_dir}",
              "chmod 600 ${local.tserver_keydir}/*.key"]
  }

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
  route_table_id         = local.primary_vpc_primary_public_subnet_route_table_id
  destination_cidr_block = var.tserver_rocky_9_amd64_vpn_cidr_block
  network_interface_id   = aws_instance.tserver_rocky_9_amd64.primary_network_interface_id
}

# Do not add this route unless we are manage the VPC
resource "aws_route" "tserver_rocky_9_amd64_return_traffic_private" {
  count                  = var.manage_vpc ? 1 : 0
  route_table_id         = module.primary-vpc[0].private_route_table_id
  destination_cidr_block = var.tserver_rocky_9_amd64_vpn_cidr_block
  network_interface_id   = aws_instance.tserver_rocky_9_amd64.primary_network_interface_id
}
