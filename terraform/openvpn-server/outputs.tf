output "ca_key" {
  value = module.pki.ca_key
  sensitive = true
}
output "ca_cert" {
  value = module.pki.ca_cert
}
output "clients" {
  value = module.pki.clients
  sensitive = true
}
output "cn_server" {
  value = local.cn_server
}
output "cn_client" {
  value = local.cn_client
}
