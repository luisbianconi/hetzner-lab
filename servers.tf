# MASTER NODE
resource "hcloud_server" "master" {
  name         = "k3s-master"
  server_type  = "cx23"
  image        = "debian-13"
  location     = "nbg1"
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.k3s_firewall.id]
  user_data    = data.template_file.master_cloud_init.rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.private_net.id
    ip         = "10.0.0.2"
  }

  labels = {
    "lab" = "true"
    "k3s_node_type" = "master"
    "k3s_token"     = random_password.k3s_token.result
  }

  depends_on = [
    hcloud_network_subnet.private_subnet
  ]
}

# WORKERS
resource "hcloud_server" "worker" {
  count        = var.worker_count
  name         = "k3s-worker-${count.index + 1}"
  server_type  = "cx23"
  image        = "debian-13"
  location     = "nbg1"
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.k3s_firewall.id]
  user_data    = data.template_file.worker_cloud_init[count.index].rendered

  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.private_net.id
  }

  labels = {
    "k3s_node_type" = "worker"
    "lab" = "true"
  }

  depends_on = [
    hcloud_server.master
  ]
}