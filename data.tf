data "http" "my_ip" {
  url = "https://api.ipify.org"
}

data "template_file" "master_cloud_init" {
  template = file("${path.module}/cloud_init_master.yml")
  vars = {
    hcloud_token                           = var.hcloud_token
    k3s_token                              = random_password.k3s_token.result
    argo_version                           = var.argo_version
    cilium_version                         = var.cilium_version
    tailscale_master_hostname              = var.tailscale_master_hostname
    tailscale_auth_key                     = var.tailscale_auth_key
    tailscale_master_advertise_routes      = join(",", var.tailscale_master_advertise_routes)
    tailscale_operator_oauth_client_id     = var.tailscale_operator_oauth_client_id
    tailscale_operator_oauth_client_secret = var.tailscale_operator_oauth_client_secret
    tailscale_nginx_hostname               = var.tailscale_nginx_hostname
  }
}

data "template_file" "worker_cloud_init" {
  count    = var.worker_count
  template = file("${path.module}/cloud_init_worker.yml")
  vars = {
    k3s_token            = random_password.k3s_token.result
    master_private_ip    = "10.0.0.2"
    worker_node_password = length(var.worker_node_passwords) > count.index ? var.worker_node_passwords[count.index] : ""
  }
}