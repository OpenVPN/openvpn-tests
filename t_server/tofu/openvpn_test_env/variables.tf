# Features that can be switched on or off
variable "enable_public_dns_zone" {
  description = "Whether to manage the public DNS zone or not"
  type        = bool
  default     = false
}

variable "enable_private_dns_zone" {
  description = "Whether to manage the private DNS zone or not"
  type        = bool
  default     = false
}

variable "enable_scheduler_stop_start" {
  description = "Whether to stop EC2 instances on a schedule"
  type        = bool
  default     = false
}

variable "enable_buildbot" {
  description = "Whether to manage buildbot"
  type        = bool
  default     = false
}

variable "enable_otterwiki" {
  description = "Whether to manage otterwiki"
  type        = bool
  default     = false
}

# Parameters
variable "public_dns_zone_name" {
  description = "Public Route 53 hosted zone name. Required when enable_public_dns_zone is true."
  type        = string
}

variable "private_dns_zone_name" {
  description = "Private Route 53 hosted zone to create and add EC2 instance A and AAAA records to. Required when enable_private_dns_zone is true."
  type        = string
}

variable "deployment" {
  description = "Informal deployment name added to EC2 instance tags"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key in the EC2 region to use for logins as the default user"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources to"
  type        = string
}

variable "primary_vpc_cidr_block" {
  description = "IPv4 CIDR block for the primary VPC"
  type        = string
}

variable "primary_vpc_primary_public_subnet_cidr_block" {
  description = "IPv4 CIDR block for the primary public subnet in the primary VPC"
  type        = string
}

variable "primary_vpc_secondary_public_subnet_cidr_block" {
  description = "IPv4 CIDR block for the secondary public subnet in the primary VPC"
  type        = string
}

variable "primary_vpc_primary_private_subnet_cidr_block" {
  description = "IPv4 CIDR block for the primary private subnet in the primary VPC"
  type        = string
}

variable "primary_vpc_secondary_private_subnet_cidr_block" {
  description = "IPv4 CIDR block for the secondary private subnet in the primary VPC"
  type        = string
}

variable "secondary_vpc_cidr_block" {
  description = "IPv4 CIDR block for the secondary VPC"
  type        = string
}

variable "secondary_vpc_primary_public_subnet_cidr_block" {
  description = "IPv4 CIDR block for the primary public subnet in the secondary VPC"
  type        = string
}

variable "secondary_vpc_secondary_public_subnet_cidr_block" {
  description = "IPv4 CIDR block for the secondary public subnet in the secondary VPC"
  type        = string
}

variable "secondary_vpc_primary_private_subnet_cidr_block" {
  description = "IPv4 CIDR block for the primary private subnet in the secondary VPC"
  type        = string
}

variable "secondary_vpc_secondary_private_subnet_cidr_block" {
  description = "IPv4 CIDR block for the secondary private subnet in the secondary VPC"
  type        = string
}

variable "vpn_cidr_block" {
  description = "VPN CIDR block. Used for return routes in AWS."
  type    = string
}

variable "ubuntu_2404_vpn_cidr_block" {
  description = "VPN CIDR block. Used for return routes in AWS."
  type        = string
}

variable "windows_vpn_cidr_block" {
  description = "VPN CIDR block. Used for return routes in AWS."
  type        = string
}

variable "tserver_rocky_9_amd64_vpn_cidr_block" {
  description = "VPN CIDR block. Used for return routes in AWS."
  type        = string
}

variable "openvpn_server_hostname" {
  description = "Hostname (not FQDN) of the OpenVPN server"
  type        = string
}

variable "tserver_rocky_9_amd64_hostname" {
  description = "Hostname (not FQDN) of the tserver instance"
  type        = string
}

variable "tserver_anchor_hostname" {
  description = "Hostname (not FQDN) of the tserver_anchor (static client) instance"
  type        = string
}

variable "tserver_client_hostname" {
  description = "Hostname (not FQDN) of the tserver_client instance"
  type        = string
}

variable "tserver_allow_ipv4" {
  description = "IPv4 CIDR block to allow connections to tserver instance from"
  type        = string
}

variable "tserver_allow_ipv6" {
  description = "IPv6 CIDR block to allow connections to tserver instance from"
  type        = string
}

variable "tserver_provisioning_ssh_private_key" {
  description = "Path to SSH private key for provisioning things that do not fit into the userdata"
  type        = string
}

variable "tserver_data_dir" {
  type        = string
  default     = "/openvpn-test-server"
  description = "Location for the OpenVPN plugins, certificates, keys and other files required by tserver, tserver-client and tserver-anchor"
}

variable "rocky_9_homedir" {
  description = "Home directory for the default AWS user on Rocky Linux 9"
  type        = string
  default     = "/home/rocky"
}

variable "rocky_9_default_user" {
  description = "Default user on Rocky Linux 9 AWS images"
  type        = string
  default     = "rocky"
}

variable "rocky_9_default_group" {
  description = "Default group on Rocky Linux 9 AWS images"
  type        = string
  default     = "rocky"
}
