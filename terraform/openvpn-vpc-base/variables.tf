variable "name" {
  description = "Name prefix to use for resources"
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
}
