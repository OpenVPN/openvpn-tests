resource "tls_private_key" "ca_key" {
  algorithm = "RSA"
}
resource "tls_private_key" "server_key" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  is_ca_certificate = true

  subject {
    common_name  = var.ca_name
    locality     = var.locality
    province     = var.province
    organization = var.organization
  }

  validity_period_hours = 24 * 365 # 1y
  early_renewal_hours   = 24 * 7   # 1w

  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_cert_request" "server_csr" {
  private_key_pem = tls_private_key.server_key.private_key_pem

  subject {
    common_name  = var.cn
    locality     = var.locality
    province     = var.province
    organization = var.organization
  }

  dns_names = [var.cn]
}

resource "tls_locally_signed_cert" "server_cert" {
  cert_request_pem   = tls_cert_request.server_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 24 * 365 # 1y
  early_renewal_hours   = 24 * 7   # 1w

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "tls_private_key" "client_key" {
  for_each = var.clients

  algorithm = each.value
}
resource "tls_cert_request" "client_csr" {
  for_each = var.clients

  private_key_pem = tls_private_key.client_key[each.key].private_key_pem

  subject {
    common_name  = each.key
  }
}

resource "tls_locally_signed_cert" "client_cert" {
  for_each = var.clients

  cert_request_pem   = tls_cert_request.client_csr[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 24 * 365 # 1y
  early_renewal_hours   = 24 * 7   # 1w

  allowed_uses = [
    "digital_signature",
    "client_auth",
  ]
}
