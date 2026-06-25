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

variable "manage_vpc" {
  description = "Whether to manage the VPC or not"
  type        = bool
  default     = true
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

variable "provision_with_private_ip" {
  description = "Provision with private IP. Only enable if VPN is configured properly."
  type        = bool
  default     = false
}

variable "transit_gateway_id" {
  description = "ID of an existing Transit Gateway to attach the primary VPC to. Leave empty to not attach to any TGW."
  type        = string
  default     = ""
}

variable "transit_gateway_destination_cidr_blocks" {
  description = "IPv4 CIDR blocks reachable over the Transit Gateway (e.g. the buildbot master VPC). Routes are added to the primary public route table, and to the private route table when manage_vpc is true. Only used when transit_gateway_id is set."
  type        = list(string)
  default     = []
}

variable "transit_gateway_destination_ipv6_cidr_blocks" {
  description = "IPv6 CIDR blocks reachable over the Transit Gateway. Routes are added to the primary public route table, and to the private route table when manage_vpc is true. Only used when transit_gateway_id is set."
  type        = list(string)
  default     = []
}

variable "external_primary_vpc_id" {
  description = "Define when manage_vpc is false: the VPC ID for the VPC."
  type        = string
  default     = ""
}

variable "external_primary_vpc_primary_public_subnet_id" {
  description = "Define when manage_vpc is false: the id of the primary public subnet in the VPC."
  type        = string
  default     = ""
}

variable "external_primary_vpc_primary_public_route_table_id" {
  description = "Define when manage_vpc is false: the id of the primary public subnet routing table in the VPC."
  type        = string
  default     = ""
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

variable "tserver_rocky_9_amd64_vpn_cidr_block" {
  description = "VPN CIDR block. Used for return routes in AWS."
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

variable "git_name" {
  type        = string
  description = "Name for Git config on the t_server server instance."
}

variable "git_email" {
  type        = string
  description = "Email for Git config on the t_server server instance."
}
