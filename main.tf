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
