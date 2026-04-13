resource "hcloud_firewall" "k3s_firewall" {
  name = "k3s-firewall"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "${chomp(data.http.my_ip.response_body)}/32"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443" # K3s API
    source_ips = [
      "${chomp(data.http.my_ip.response_body)}/32"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "1-65535" # Allow node-to-node control/data plane traffic on private network
    source_ips = [
      hcloud_network.private_net.ip_range
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "1-65535" # Allow node-to-node overlay/DNS traffic on private network
    source_ips = [
      hcloud_network.private_net.ip_range
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "8472" # Flannel/Cilium VXLAN
    source_ips = [
      hcloud_network.private_net.ip_range
    ]
  }
}