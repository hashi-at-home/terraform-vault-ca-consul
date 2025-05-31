# PKI Secrets backend for Consul CA
resource "vault_mount" "consul_root_ca" {
  path = "consul-root-ca"
  type = "pki"
  description = "PKI Root CA for Consul"
  # Tune lease for default 1 day, max 1 year
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds = 31536000
}

locals {
  consul_ca_pub_key = file("${path.module}/consul-agent-ca.pem")
}

# CA cert and key is created with consul tls create
# in the first iteration, we assume this is already present
resource "vault_pki_secret_backend_config_ca" "consul_root_ca" {
  backend = vault_mount.consul_root_ca.path
  pem_bundle = join("\n", [file("${path.module}/consul-agent-ca.pem"), file("${path.module}/consul-agent-ca-key.pem")])
}

resource "vault_pki_secret_backend_crl_config" "consul_root_ca" {
  backend = vault_mount.consul_root_ca.path
  expiry = "72h"
  disable = false
  auto_rebuild = true
  max_crl_entries = 100
}

resource "vault_pki_secret_backend_role" "consul_root_ca" {
  backend = vault_mount.consul_root_ca.path
  name = "hashi-at-home"
  allow_localhost = true
  allowed_domains = ["consul", "hashiatho.me", "orca-ordinal.ts.net"]
  allow_subdomains = true
  ttl = 86400
  max_ttl = 259200
  allow_ip_sans = true
  server_flag = true
}

# Configure the backend to auto tidy
resource "vault_pki_secret_backend_config_auto_tidy" "consul_root_ca" {
  backend = vault_mount.consul_root_ca.path
  enabled = true
  tidy_cert_store = true
  interval_duration = "1h"
  tidy_revoked_certs = true
}
