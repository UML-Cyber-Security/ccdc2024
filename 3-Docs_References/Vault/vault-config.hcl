ui = true
api_addr = "https://127.0.0.1:8200" 
limit_core = 0


storage "consul" {
  scheme        = "https"
  tls_ca_file   = "/etc/pem/vault.ca"
  tls_cert_file = "/etc/pem/vault.cert"
  tls_key_file  = "/etc/pem/vault.key"
}

# Logging Configuration
log_level  = "info"
log_format = "json"

# Telemetry Configuration (Optional)
telemetry {
  statsd_address   = "127.0.0.1:8125"
  disable_hostname = true
  prefix           = "vault"
}