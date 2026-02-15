# Azure Deployment

Run OpenClaw 24/7 on Azure VM with Docker.

## Goal

Persistent OpenClaw Gateway on Azure VM using Docker, with durable state and safe restart behavior.

## Prerequisites

- Azure account
- SSH key at `~/.ssh/id_rsa.pub`
- .env with required keys (see .env_example)

## Quick Path

```bash
# 1. Create resource group + VM
az group create -n openclaw -l uaenorth
az vm create \
  --resource-group openclaw \
  --name openclaw \
  --image Ubuntu2204 \
  --size Standard_D2s_v3 \
  --admin-user azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub \
  --custom-data cloud-init.yaml

# 2. SSH into VM
ssh azureuser@<vm-ip>

# 3. Configure and start
cd /opt/openclaw-docker
cp .env_example .env
nano .env
make build
make up
make provision
```

## Step-by-Step

### 1. Create Resource Group

```bash
az group create -n openclaw -l uaenorth
```

### 2. Create VM with cloud-init

```bash
az vm create \
  --resource-group openclaw \
  --name openclaw \
  --image Ubuntu2204 \
  --size Standard_D2s_v3 \
  --admin-user azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub \
  --custom-data cloud-init.yaml
```

**Options:**
- `--size Standard_D2s_v3` - 2 vCPU, 8GB RAM (~$45/mo)
- `--boot-disk-size 30` - 30GB SSD
- `--public-ip-sku Standard` - Static public IP

### 3. SSH into VM

```bash
ssh azureuser@<vm-ip>
```

### 4. Configure .env

```bash
cd /opt/openclaw-docker
cp .env_example .env
nano .env
```

Required:
- `COMPASS_API_KEY` - Model provider key
- `TELEGRAM_BOT_TOKEN` - Telegram bot token
- `OPENCLAW_GATEWAY_AUTH_TOKEN` - Gateway auth token

### 5. Build and Start

```bash
make build
make up
make provision
```

## What Persists

| Component | Host Location | Persistence |
|----------|--------------|-------------|
| Gateway config | data/.openclaw | Volume mount |
| Workspace | data/workspace | Volume mount |
| Clippy auth | data/clippy | Volume mount |
| Whoop auth | data/whoop | Volume mount |
| Docker image | Container | Rebuild if updated |

## Updates

```bash
cd /opt/openclaw-docker
git pull
make build
make up
```

## Troubleshooting

### Check cloud-init status
```bash
cloud-init status
```

### Check container logs
```bash
make logs
```

### Check container status
```bash
make status
```

### Restart container
```bash
make down && make up
```

### Rebuild from scratch
```bash
make down
docker system prune -af
make build
make up
```

## VM Specifications

| Setting | Value | Notes |
|---------|-------|-------|
| Size | Standard_D2s_v3 | 2 vCPU, 8GB RAM |
| Disk | 30GB SSD | Default |
| Region | uaenorth | UAE North |
| OS | Ubuntu 22.04 | LTS |
| SSH | Key-only | No password |

## Cost

- VM: ~$45/month (D2s_v3)
- Public IP: ~$3/month
- Storage: included
- **Total: ~$50/month**
