resource "aws_instance" "tserver_client" {
  ami                         = module.ami.rocky_9_id
  associate_public_ip_address = true
  disable_api_termination     = true
  ebs_optimized               = true
  instance_type               = "t3.small"
  key_name                    = var.key_name
  source_dest_check           = false
  subnet_id                   = module.primary-vpc.primary_public_subnet_id
  tags                        = { "Name": "tserver-client",
                                  "Role" : "Static tserver OpenVPN client",
                                  "tostop" : "true",
                                  "Distro" : "Rocky",
                                  "Login" : "rocky" }
  user_data                   = module.tserver_client_user_data.user_data 
  vpc_security_group_ids      = [ module.primary-vpc-standard-sg.id, ]

  # Copy OpenVPN certificates and keys. This needs to be done using a
  # provisioner as the content will not fit into the userdata.
  connection {
    type        = "ssh"
    user        = "rocky"
    host        = self.private_ip
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
    content     = module.pki.clients["tserver-client-22"]["cert"]
    destination = "${local.tserver_keydir}/client-22.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-22"]["key"]
    destination = "${local.tserver_keydir}/client-22.key"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-23"]["cert"]
    destination = "${local.tserver_keydir}/client-23.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-23"]["key"]
    destination = "${local.tserver_keydir}/client-23.key"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-24"]["cert"]
    destination = "${local.tserver_keydir}/client-24.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-24"]["key"]
    destination = "${local.tserver_keydir}/client-24.key"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-25"]["cert"]
    destination = "${local.tserver_keydir}/client-25.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-25"]["key"]
    destination = "${local.tserver_keydir}/client-25.key"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-26"]["cert"]
    destination = "${local.tserver_keydir}/client-26.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-26"]["key"]
    destination = "${local.tserver_keydir}/client-26.key"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-27"]["cert"]
    destination = "${local.tserver_keydir}/client-27.crt"
  }

  provisioner "file" {
    content     = module.pki.clients["tserver-client-27"]["key"]
    destination = "${local.tserver_keydir}/client-27.key"
  }

  provisioner "remote-exec" {
    inline = ["sudo chown -R ${var.rocky_9_default_user}:${var.rocky_9_default_group} ${var.tserver_data_dir}",
              "chmod 600 ${local.tserver_keydir}/*.key",
              "ln -s ${local.tserver_keydir}/client-27.crt ${local.tserver_keydir}/client-master.crt",
              "ln -s ${local.tserver_keydir}/client-27.key ${local.tserver_keydir}/client-master.key"]

  }

  root_block_device {
    volume_size = 50
    tags        = { "Name" : "tserver-client",
                    "Role" : "tserver client", }
  }

  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

resource "aws_route53_record" "tserver_client_private_ipv4" {
  count   = var.enable_private_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.private_dns_zone[0].zone_id
  name    = "${var.tserver_client_hostname}.${var.private_dns_zone_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.tserver_client.private_ip]
}

resource "aws_route53_record" "tserver_client_ipv6" {
  count   = var.enable_private_dns_zone ? 1 : 0
  zone_id = aws_route53_zone.private_dns_zone[0].zone_id
  name    = "${var.tserver_client_hostname}.${var.private_dns_zone_name}"
  type    = "AAAA"
  ttl     = 300
  records = aws_instance.tserver_client.ipv6_addresses
}
