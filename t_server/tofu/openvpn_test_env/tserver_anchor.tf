resource "aws_instance" "tserver_anchor" {
  ami                         = module.ami.rocky_9_id
  associate_public_ip_address = true
  disable_api_termination     = true
  ebs_optimized               = true
  instance_type               = "t3.small"
  key_name                    = var.key_name
  source_dest_check           = false
  subnet_id                   = local.primary_vpc_primary_public_subnet_id
  tags                        = { "Name": "tserver-anchor",
                                  "Role" : "Static tserver OpenVPN client",
                                  "tostop" : "true",
                                  "Distro" : "Rocky",
                                  "Login" : "rocky" }
  user_data                   = module.tserver_anchor_user_data.user_data
  vpc_security_group_ids      = [ module.primary-vpc-standard-sg.id, ]

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
    content     = module.pki.clients["tserver-anchor-200"]["cert"]
    destination = "${local.tserver_keydir}/anchor-200.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-anchor-200"]["key"]
    destination = "${local.tserver_keydir}/anchor-200.key"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-anchor-207"]["cert"]
    destination = "${local.tserver_keydir}/anchor-207.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-anchor-207"]["key"]
    destination = "${local.tserver_keydir}/anchor-207.key"
  }

  provisioner "remote-exec" {
    inline = ["sudo chown -R ${var.rocky_9_default_user}:${var.rocky_9_default_group} ${var.tserver_data_dir}",
              "chmod 600 ${local.tserver_keydir}/*.key"]
  }

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
