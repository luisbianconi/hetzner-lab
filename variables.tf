variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "worker_count" {
  default = 2
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key used to auto-join nodes to tailnet"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tailscale_master_advertise_routes" {
  description = "Routes advertised by the master node over Tailscale"
  type        = list(string)
  default     = ["10.0.0.0/24", "172.16.0.0/16", "172.17.0.0/16"]
}

variable "tailscale_operator_oauth_client_id" {
  description = "Tailscale OAuth client id for Kubernetes operator"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tailscale_operator_oauth_client_secret" {
  description = "Tailscale OAuth client secret for Kubernetes operator"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argo_version" {
  description = "ArgoCD Version used for testing"
  type        = string
  default     = ""
}

variable "cilium_version" {
  description = "Cilium Version used for testing"
  type        = string
  default     = ""
}

variable "tailscale_nginx_hostname" {
  description = "Hostname to use for Tailscale Ingress exposing nginx-test"
  type        = string
  default     = "nginx-test"
}

variable "tailscale_master_hostname" {
  description = "MagicDNS hostname used to access Kubernetes API over Tailscale"
  type        = string
  default     = "k3s-master.echo-fish.ts.net"
}

variable "worker_node_passwords" {
  description = "Stable per-worker node passwords used by k3s agent (index 0 -> worker-1, index 1 -> worker-2, etc.)"
  type        = list(string)
  default     = []
  sensitive   = true
}

variable "ssh_key_name" {
  description = "The name of the SSH key in Hetzner Cloud"
  type        = string
  default     = "luisbianconi-key"
}

variable "ssh_public_key" {
  description = "Path to the public SSH key"
  type        = string
}
