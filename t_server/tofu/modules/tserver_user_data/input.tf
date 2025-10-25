variable "git_name" {
  type        = string
  description = "Name for Git config. Mainly useful on the t_server server instance."
  default     = ""
}

variable "git_email" {
  type        = string
  description = "Email for Git config. Mainly useful on the t_server server instance."
  default     = ""
}

variable "hostname" {
  type        = string
  description = "Hostname for the system"
}

variable "private_dns_zone_name" {
  type        = string
  default     = ""
  description = "Private DNS zone name"
}

variable "tserver_fqdn" {
  type        = string
  description = "FQDN for t_server server instance"
}

variable "my_fqdn" {
  type        = string
  description = "FQDN for this system"
}

variable "tserver" {
  type        = bool
  default     = false
  description = "Is this a t_server instance?"
}

variable "tserver_anchor" {
  type        = bool
  default     = false
  description = "Is this a t_server anchor instance?"
}

variable "tserver_client" {
  type        = bool
  default     = false
  description = "Is this a t_server client instance?"
}

variable "tserver_allow_ipv4" {
  type        = string
  default     = ""
  description = "IPv4 range allowed to access services on t_server server"
}

variable "tserver_allow_ipv6" {
  type        = string
  default     = ""
  description = "IPv6 range allowed to access services on t_server server"
}

variable "default_user" {
  type        = string
  description = "Default operating system user"
}

variable "default_group" {
  type        = string
  description = "Primary group for the default operating system user"
}

variable "ssh_private_key" {
  type        = string
  default     = ""
  description = "t_server SSH private key"
}

variable "ssh_public_key" {
  type        = string
  default     = ""
  description = "t_server SSH public key"
}

variable "data_dir" {
  type        = string
  description = "Location for the OpenVPN plugins, certificates, keys and other files required by tserver, tserver-client and tserver-anchor"
}
