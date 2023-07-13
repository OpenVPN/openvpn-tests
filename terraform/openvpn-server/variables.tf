variable "openvpn_repo" {
  description = "OpenVPN 2 Git Repo URI"
  type        = string
  default     = "https://github.com/OpenVPN/openvpn.git"
}

variable "ovpn_dco_repo" {
  description = "DCO Linux Kernel Module Git Repo URI"
  type        = string
  default     = "https://github.com/OpenVPN/ovpn-dco.git"
}

variable "test_repo" {
  description = "Tests Git Repo URI"
  type        = string
  default     = "https://github.com/OpenVPN/openvpn-tests.git"
}

variable "openvpn_branch" {
  description = "Branch name to check out in openvpn_repo"
  type        = string
  default     = "master"
}

variable "ovpn_dco_branch" {
  description = "Branch name to check out in ovpn_dco_repo"
  type        = string
  default     = "master"
}

variable "test_branch" {
  description = "Branch name to check out in test_repo"
  type        = string
  default     = "main"
}

variable "cluster_name" {
  description = "Name of the test cluster"
  type        = string
}

variable "dns_zone_name" {
  description = "Route53 DNS Zone to create records in"
  type        = string
}

variable "dns_host_name" {
  description = "Hostname to use for server"
  type        = string
  default     = "openvpn-test"
}

variable "environment" {
  description = "Name of the environment (used e.g. for puppet)"
  type        = string
  default     = "development"
}

variable "email" {
  description = "Email address of the main contact for this cluster"
  type        = string
}

variable "owner" {
  description = "Name of the main contact for this cluster"
  type        = string
}

variable "region" {
  description = "AWS Region to run the cluster in"
  type        = string
}

variable "cidr_prefix" {
  description = "CIDR prefix to use for the VPC"
  type        = string
  default     = "10.3"
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}$", var.cidr_prefix))
    error_message = "The first two tuples of a valid CIDR, e.g. \"10.3\"."
  }
}

variable "ssh_pub_key" {
  description = "Public key to install on instances for SSH access"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDONpIE580IDPbCrwVQBL6BR2RG9dsGw831cBncUGCF+D66FY2mbIhl/GgpepQzkBcGgfXDYSSnp5Jvo0q5L8sZ5IFtZfzJtaUMcGbmPIH7TUit5HuRPRXV1YCjc6umWzjgm0vki28xtzsM7JEch2Al1ckegFW9z7JvM1RkO924f5aP2qVn9Fl8tZHMdOdp1MvLEwE5lw3+psAmMGEFsJFnVMqlmHsiaTfWRZ4cILmFU2pauRxm2YIlalIIQQ90bk85ydAT+aUKZoJqb0WiUBlhK9Ly+YWNomWhZaQcFDlrmyLCPk42qIj/yIU5wqL4iLJIYz7Ol9EgBw3tyeyggq1pk9JGjWzb4SicUckjEKo8K4SOQXTnk4k+E8BMVGz8T/QhQYd/4vDFZ+waKsqgyLCJyn/ACALWe1t86Y8HiGw8tZAmDNDPq4zoJZGyoBWa9X6C/+ja042HtPuBP/CFpOolFEGeb/bSx1I1Eg1rnzZLkHksJaKhPV+n2dh54Dd5ceE= pg_test"
}
