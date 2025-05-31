# PKI Secrets backend for Consul CA
resource "vault_mount" "consul_root_ca" {
  path = "consul-root-ca"
  type = "pki"
  description = "PKI Root CA for Consul"
  default_lease_ttl_seconds = 46800

}
