output "ca_cert" {
  value = tls_self_signed_cert.ca.cert_pem
}
output "ca_key" {
  value     = tls_private_key.ca_key.private_key_pem
  sensitive = true
}
output "server_cert" {
  value = tls_locally_signed_cert.server_cert.cert_pem
}
output "server_key" {
  value     = tls_private_key.server_key.private_key_pem
  sensitive = true
}
output "clients" {
  value = { for client in keys(var.clients): client => {
    cert = tls_locally_signed_cert.client_cert[client].cert_pem
    key = tls_private_key.client_key[client].private_key_pem
  } }
  sensitive = true
}
