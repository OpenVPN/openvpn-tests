module "ami" {
  source = "../modules/ami"
}

# Main production VPC
module "primary-vpc" {
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

module "secondary-vpc" {
  source                              = "github.com/Puppet-Finland/opentofu-vpc?ref=1.1.0"
  basename                            = "office"
  region                              = "eu-central-1"
  manage_ipv4_nat_gateway             = false
  vpc_cidr_block                      = var.secondary_vpc_cidr_block
  primary_public_subnet_cidr_block    = var.secondary_vpc_primary_public_subnet_cidr_block
  secondary_public_subnet_cidr_block  = var.secondary_vpc_secondary_public_subnet_cidr_block
  primary_private_subnet_cidr_block   = var.secondary_vpc_primary_private_subnet_cidr_block
  secondary_private_subnet_cidr_block = var.secondary_vpc_secondary_private_subnet_cidr_block
}

module "scheduler-stop-start" {
  count  = var.enable_scheduler_stop_start ? 1 : 0
  source = "../modules/scheduler-stop-start"
}

module "pki" {
  source  = "../modules/openvpn-test-pki"
  cn      = local.cn
  clients = { tserver-anchor    = "RSA",
              tserver-client-22 = "RSA",
              tserver-client-23 = "RSA",
              tserver-client-24 = "RSA",
              tserver-client-25 = "RSA",
              tserver-client-26 = "RSA",
              tserver-client-27 = "RSA", }
}

module "tserver_rocky_9_amd64_user_data" {
  source          = "../modules/tserver_user_data"
  hostname        = var.tserver_rocky_9_amd64_hostname
  tserver_fqdn    = local.tserver_rocky_9_amd64_fqdn
  my_fqdn         = local.tserver_rocky_9_amd64_fqdn
  tserver         = true
  default_user    = var.rocky_9_default_user
  default_group   = var.rocky_9_default_user
  ssh_private_key = sshkey_ed25519_key_pair.tserver.private_key_pem
  ca_cert         = module.pki.ca_cert
  server_cert     = module.pki.server_cert
  server_key      = module.pki.server_key
  data_dir        = var.tserver_data_dir
}

module "tserver_anchor_user_data" {
  source          = "../modules/tserver_user_data"
  hostname        = var.tserver_anchor_hostname 
  tserver_fqdn    = local.tserver_rocky_9_amd64_fqdn
  my_fqdn         = local.tserver_anchor_fqdn
  tserver_anchor = true
  default_user    = var.rocky_9_default_user 
  default_group   = var.rocky_9_default_user
  ssh_public_key  = sshkey_ed25519_key_pair.tserver.public_key
  ca_cert         = module.pki.ca_cert
  anchor_cert     = module.pki.clients["tserver-anchor"]["cert"]
  anchor_key      = module.pki.clients["tserver-anchor"]["key"]
  data_dir        = var.tserver_data_dir
}

module "tserver_client_user_data" {
  source          = "../modules/tserver_user_data"
  hostname        = var.tserver_client_hostname 
  tserver_fqdn    = local.tserver_rocky_9_amd64_fqdn
  my_fqdn         = local.tserver_client_fqdn
  tserver_client  = true
  default_user    = var.rocky_9_default_user 
  default_group   = var.rocky_9_default_user
  ssh_public_key  = sshkey_ed25519_key_pair.tserver.public_key
  ca_cert         = module.pki.ca_cert
  data_dir        = var.tserver_data_dir
}

module "otf-misc" {
  source = "../modules/otf-misc"
}
