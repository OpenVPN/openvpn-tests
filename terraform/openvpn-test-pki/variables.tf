variable "cn" {
  description = "CN/DNS name value for Cert"
  type        = string
}
variable "ca_name" {
  description = "CN name value for CA Cert"
  type        = string
  default     = "OpenVPN Test CA"
}
variable "locality" {
  description = "locality value for all certs"
  type        = string
  default     = "test server"
}
variable "province" {
  description = "province value for all certs"
  type        = string
  default     = "AWS"
}
variable "organization" {
  description = "organization value for all certs"
  type        = string
  default     = "OpenVPN Community"
}
variable "clients" {
  description = "list of client CNs and key type to use"
  type        = map(string)
  default     = { test_client = "RSA" }
}
