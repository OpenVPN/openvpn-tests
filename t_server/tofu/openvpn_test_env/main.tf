module "ami" {
  source = "../modules/ami"
}

# Main production VPC
module "primary-vpc" {
  count                               = var.manage_vpc ? 1 : 0
  source                              = "github.com/Puppet-Finland/opentofu-vpc?ref=1.1.0"
  basename                            = "production"
  region                              = var.region
  manage_ipv4_nat_gateway             = false
  vpc_cidr_block                      = var.primary_vpc_cidr_block
  primary_public_subnet_cidr_block    = var.primary_vpc_primary_public_subnet_cidr_block
  secondary_public_subnet_cidr_block  = var.primary_vpc_secondary_public_subnet_cidr_block
  primary_private_subnet_cidr_block   = var.primary_vpc_primary_private_subnet_cidr_block
  secondary_private_subnet_cidr_block = var.primary_vpc_secondary_private_subnet_cidr_block
}

module "scheduler-stop-start" {
  count  = var.enable_scheduler_stop_start ? 1 : 0
  source = "../modules/scheduler-stop-start"
}

module "pki" {
  source  = "../modules/openvpn-test-pki"
  cn      = local.cn
  clients = {
    tserver-anchor-200 = "RSA",
    tserver-anchor-207 = "RSA",
    tserver-client-22 = "RSA",
    tserver-client-23 = "RSA",
    tserver-client-24 = "RSA",
    tserver-client-25 = "RSA",
    tserver-client-26 = "RSA",
    tserver-client-27 = "RSA",
    tserver-client-28 = "RSA",
  }
}

module "tserver_rocky_9_amd64_user_data" {
  source                = "../modules/tserver_user_data"
  hostname              = var.tserver_rocky_9_amd64_hostname
  private_dns_zone_name = var.private_dns_zone_name
  tserver_fqdn          = local.tserver_rocky_9_amd64_fqdn
  tserver_private_fqdn  = local.tserver_rocky_9_amd64_private_fqdn
  my_fqdn               = local.tserver_rocky_9_amd64_fqdn
  tserver               = true
  tserver_allow_ipv4    = local.primary_vpc_cidr_block
  tserver_allow_ipv6    = local.primary_vpc_ipv6_cidr_block
  default_user          = var.rocky_9_default_user
  default_group         = var.rocky_9_default_user
  ssh_private_key       = sshkey_ed25519_key_pair.tserver.private_key_pem
  data_dir              = var.tserver_data_dir
  git_name              = var.git_name
  git_email             = var.git_email
}

module "tserver_anchor_user_data" {
  source               = "../modules/tserver_user_data"
  hostname             = var.tserver_anchor_hostname
  tserver_fqdn         = local.tserver_rocky_9_amd64_fqdn
  tserver_private_fqdn = local.tserver_rocky_9_amd64_private_fqdn
  my_fqdn              = local.tserver_anchor_fqdn
  tserver_anchor       = true
  default_user         = var.rocky_9_default_user
  default_group        = var.rocky_9_default_user
  ssh_public_key       = sshkey_ed25519_key_pair.tserver.public_key
  data_dir             = var.tserver_data_dir
  git_name             = var.git_name
  git_email            = var.git_email
}

module "tserver_client_user_data" {
  source               = "../modules/tserver_user_data"
  hostname             = var.tserver_client_hostname
  tserver_fqdn         = local.tserver_rocky_9_amd64_fqdn
  tserver_private_fqdn = local.tserver_rocky_9_amd64_private_fqdn
  my_fqdn              = local.tserver_client_fqdn
  tserver_client       = true
  default_user         = var.rocky_9_default_user
  default_group        = var.rocky_9_default_user
  ssh_public_key       = sshkey_ed25519_key_pair.tserver.public_key
  data_dir             = var.tserver_data_dir
  git_name             = var.git_name
  git_email            = var.git_email
}
