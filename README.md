# Terraform K3s Lab (Generic)

This repository provisions a small Kubernetes lab environment in a cloud provider using Terraform.

It is designed for learning and testing GitOps, networking, and cluster add-ons on a lightweight Kubernetes distribution (K3s).

## What This Project Does

- Provisions infrastructure for one control-plane node and multiple worker nodes
- Creates a private network and subnet for node-to-node communication
- Applies firewall rules for SSH, Kubernetes API access, and service traffic
- Bootstraps K3s on the control-plane and joins worker nodes automatically
- Optionally installs cluster add-ons during bootstrap (for example CNI, GitOps tooling, and remote access/operator components)
- Fetches and writes a local kubeconfig after cluster provisioning

## Repository Layout

- `providers.tf`: Terraform and provider requirements
- `variables.tf`: Input variables (includes sensitive and non-sensitive settings)
- `network.tf`: Network and subnet resources
- `security.tf`: Firewall rules
- `servers.tf`: Control-plane and worker server resources
- `data.tf`: Template rendering and external data sources
- `main.tf`: Provisioning helpers, waits, local kubeconfig generation
- `outputs.tf`: Terraform outputs
- `cloud_init_master.yml`: Control-plane bootstrap steps
- `cloud_init_worker.yml`: Worker bootstrap steps
- `fetch_kubeconfig.sh`: Script to retrieve kubeconfig from the control-plane

## Prerequisites

- Terraform (recent version, 1.x recommended)
- Cloud account and API token for the configured provider
- SSH key pair available on your machine
- Bash and SSH client available locally

## Quick Start

1. Clone the repository and enter the project directory.
2. Create your own variable file (do not commit secrets):

```bash
cp terraform.tfvars.example terraform.tfvars
```

If an example file is not available, create `terraform.tfvars` manually.

3. Fill required variables in `terraform.tfvars` using your own values, for example:

```hcl
hcloud_token   = "<YOUR_CLOUD_API_TOKEN>"
ssh_public_key = "<YOUR_PUBLIC_SSH_KEY_CONTENT>"

# Optional values
worker_count = 2
# tailscale_auth_key = "<OPTIONAL_REMOTE_ACCESS_KEY>"
# tailscale_operator_oauth_client_id = "<OPTIONAL_OAUTH_CLIENT_ID>"
# tailscale_operator_oauth_client_secret = "<OPTIONAL_OAUTH_CLIENT_SECRET>"
```

4. Initialize and plan:

```bash
terraform init
terraform plan
```

5. Apply:

```bash
terraform apply
```

6. Verify outputs:

```bash
terraform output
```

## Node Topology and Scaling

This project always creates one control-plane (master) node.

The number of worker nodes is controlled by `worker_count`.

Common values:

- `worker_count = 0`: Single-node cluster (control-plane only). Good for quick testing and low cost.
- `worker_count = 2`: Small multi-node lab. Good default for validating scheduling, networking, and basic high-availability behaviors.
- `worker_count >= 3`: Larger lab for scaling tests and stronger workload distribution.

Example:

```hcl
worker_count = 0
```

or

```hcl
worker_count = 2
```

or

```hcl
worker_count = 4
```

If you increase or decrease `worker_count`, Terraform will create or destroy worker nodes to match the desired state.

Optional advanced setting:

- `worker_node_passwords` can be used to provide stable per-worker passwords.
- The list index maps to workers in order (index 0 = worker-1, index 1 = worker-2, and so on).
- If not provided, workers use fallback node identity behavior during bootstrap.

## Accessing the Cluster

After a successful apply, kubeconfig is fetched locally by the project automation.

Typical workflow:

```bash
export KUBECONFIG=$HOME/.kube/config
kubectl get nodes
```

## Tailscale (Optional)

This project can optionally integrate Tailscale for private access to the Kubernetes API and for exposing selected services through the Tailscale operator.

When enabled:

- The control-plane node joins your tailnet during bootstrap
- The Kubernetes API endpoint can be reached via a Tailscale/MagicDNS hostname
- Routes can be advertised from the control-plane node (if configured)
- The Tailscale Kubernetes operator can be installed using OAuth credentials

Common variables related to this integration:

- `tailscale_auth_key`: Auth key used by nodes to join tailnet
- `tailscale_master_hostname`: Hostname used for kubeconfig API endpoint
- `tailscale_master_advertise_routes`: Routes announced by control-plane node
- `tailscale_operator_oauth_client_id`: OAuth client ID for operator install
- `tailscale_operator_oauth_client_secret`: OAuth client secret for operator install
- `tailscale_nginx_hostname`: Example hostname used by test ingress setup

Minimal example (placeholders only):

```hcl
tailscale_auth_key                     = "<OPTIONAL_TAILSCALE_AUTH_KEY>"
tailscale_master_hostname              = "<OPTIONAL_TAILSCALE_DNS_NAME>"
tailscale_master_advertise_routes      = ["10.0.0.0/24", "172.16.0.0/16", "172.17.0.0/16"]
tailscale_operator_oauth_client_id     = "<OPTIONAL_OAUTH_CLIENT_ID>"
tailscale_operator_oauth_client_secret = "<OPTIONAL_OAUTH_CLIENT_SECRET>"
```

If these values are left empty, Tailscale-related bootstrap steps are skipped.

## Security and Sensitive Data

- Never commit API tokens, auth keys, OAuth secrets, or private keys
- Keep `terraform.tfvars` private
- Treat Terraform state as sensitive data
- Restrict SSH and API access to trusted source IP ranges

## Cleanup

To destroy all managed resources:

```bash
terraform destroy
```

## Notes

- This README is intentionally generic and avoids environment-specific identifiers.
- Adjust instance sizes, regions, CIDRs, and add-on versions to match your requirements.
