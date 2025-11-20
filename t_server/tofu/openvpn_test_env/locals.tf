locals {
  cn                                 = "tserver.${var.public_dns_zone_name}"
  tserver_anchor_fqdn                = "${var.tserver_anchor_hostname}.${var.public_dns_zone_name}"
  tserver_client_fqdn                = "${var.tserver_client_hostname}.${var.public_dns_zone_name}"
  tserver_rocky_9_amd64_fqdn         = "${var.tserver_rocky_9_amd64_hostname}.${var.public_dns_zone_name}"
  tserver_rocky_9_amd64_private_fqdn = "${var.tserver_rocky_9_amd64_hostname}.${var.private_dns_zone_name}"
  tserver_keydir                     = "${var.tserver_data_dir}/keys"
}
