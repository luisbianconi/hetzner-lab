resource "null_resource" "wait_for_k3s" {
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do echo 'Waiting for k3s...'; sleep 5; done"
    ]
    connection {
      type        = "ssh"
      user        = "root"
      private_key = file(pathexpand("~/.ssh/id_ed25519"))
      host        = hcloud_server.master.ipv4_address
      timeout     = "10m"
    }
  }

  depends_on = [hcloud_server.master]
}

resource "null_resource" "write_local_kubeconfig" {
  triggers = {
    master_id         = hcloud_server.master.id
    master_public_ip  = hcloud_server.master.ipv4_address
    api_hostname      = var.tailscale_master_hostname
    fetch_script_hash = filesha1("${path.module}/fetch_kubeconfig.sh")
    always_run        = timestamp()
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "bash ${path.module}/fetch_kubeconfig.sh \"${path.module}\" \"${hcloud_server.master.ipv4_address}\" \"${var.tailscale_master_hostname}\" \"${pathexpand("~/.ssh/id_ed25519")}\""
  }

  depends_on = [null_resource.wait_for_k3s]
}

resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

resource "hcloud_ssh_key" "default" {
  name       = var.ssh_key_name
  public_key = var.ssh_public_key

  labels = {
    "lab" = "true"
  }
}

resource "hcloud_rdns" "master_rdns" {
  server_id  = hcloud_server.master.id
  ip_address = hcloud_server.master.ipv4_address
  dns_ptr    = "master.k3s.local"
}


