resource "hcloud_network" "private_net" {
  name     = "k3s-private-net"
  ip_range = "10.0.0.0/16"

labels = {
  lab = "true"
}
}

resource "hcloud_network_subnet" "private_subnet" {
  network_id   = hcloud_network.private_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}