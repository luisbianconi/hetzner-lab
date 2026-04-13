output "master_ip" {
  description = "Public IP address of the master server"
  value       = hcloud_server.master.ipv4_address
}

output "kubeconfig_path" {
  description = "Local kubeconfig path written by Terraform"
  value       = "${path.module}/kube/config"
}

output "kubeconfig_server_endpoint" {
  description = "Kubernetes API endpoint configured in local kubeconfig"
  value       = "https://${var.tailscale_master_hostname}:6443"
}
