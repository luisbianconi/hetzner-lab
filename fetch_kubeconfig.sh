#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <module_dir> <master_public_ip> <tailscale_master_hostname> <ssh_private_key_path>"
  exit 1
fi

MODULE_DIR="$1"
MASTER_IP="$2"
TAILSCALE_HOSTNAME="$3"
SSH_KEY="$4"
KUBECONFIG_PATH="${HOME}/.kube/config"

if [ ! -f "${SSH_KEY}" ]; then
  echo "ERROR: SSH key not found at ${SSH_KEY}"
  exit 1
fi

mkdir -p "${HOME}/.kube"

ssh \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -i "${SSH_KEY}" \
  "root@${MASTER_IP}" \
  "cat /etc/rancher/k3s/k3s.yaml" > "${KUBECONFIG_PATH}"

if [ ! -s "${KUBECONFIG_PATH}" ]; then
  echo "ERROR: kubeconfig was not written or is empty at ${KUBECONFIG_PATH}"
  exit 1
fi

sed -i -E "s#https://[^:]+:6443#https://${TAILSCALE_HOSTNAME}:6443#g" "${KUBECONFIG_PATH}"
chmod 600 "${KUBECONFIG_PATH}"

echo "kubeconfig written to ${KUBECONFIG_PATH}"
