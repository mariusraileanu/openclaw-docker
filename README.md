# OpenClaw Docker

Single-container OpenClaw runtime with essential skills.

## Skills Included

- **clippy** - M365 calendar/email
- **tavily** - Web search
- **playwright** - Browser automation
- **goplaces** - Places/location
- **whoop** - WHOOP integration
- **weather** - Weather data

## Quick Start

### Local

```bash
# 1. Copy env template
cp .env_example .env

# 2. Edit .env with your keys
nano .env

# 3. Build and start
make build
make up

# 4. Provision
make provision
```

### Azure VM

```bash
# On laptop - create VM with cloud-init
az vm create \
  --resource-group <rg> \
  --name openclaw \
  --image Ubuntu2204 \
  --size Standard_D4s_v5 \
  --admin-user azureuser \
  --ssh-key-value ~/.ssh/id_rsa.pub \
  --custom-data cloud-init.yaml

# SSH into VM
ssh azureuser@<vm-ip>

# In VM:
git clone <repo-url>
cd openclaw-docker
cp .env_example .env
nano .env
make up
make provision
```

## Make Commands

| Command | Description |
|---------|-------------|
| `make build` | Build Docker image |
| `make up` | Start container |
| `make down` | Stop container |
| `make status` | Show container status |
| `make logs` | Follow container logs |
| `make provision` | Provision and restart |
| `make auth-sync` | Sync Clippy + Whoop auth |
| `make validate` | Validate environment |

## Environment Variables

Required in `.env`:

| Variable | Description |
|----------|-------------|
| `COMPASS_API_KEY` | Model provider API key |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token |
| `OPENCLAW_GATEWAY_AUTH_TOKEN` | Gateway auth token |

Optional:

| Variable | Description |
|----------|-------------|
| `WHOOP_CLIENT_ID` | Whoop client ID |
| `WHOOP_CLIENT_SECRET` | Whoop client secret |
| `WHOOP_EMAIL` | Whoop email (password auth) |
| `WHOOP_PASSWORD` | Whoop password |

## Data Persistence

| Path | Description |
|------|-------------|
| `data/.openclaw` | Runtime state |
| `data/workspace` | Agent workspace |
| `data/clippy` | Clippy auth |
| `data/whoop` | Whoop credentials |

## Security

- `.env` must NOT be committed
- Container runs as non-root user
- Read-only root filesystem by default
- No secrets in config files
- Telegram/Whoop tokens via `.env` only

## Adding Skills

Skills are installed at build time via clawhub in Dockerfile. To add new skills:

1. Edit `config/versions.env` - add skill version
2. Edit `Dockerfile` - add `npx clawhub install` command
3. Rebuild: `make build`

## Structure

```
.
├── Makefile
├── Dockerfile
├── docker-compose.yml
├── cloud-init.yaml
├── .env_example
├── .gitignore
├── config/
│   ├── versions.env
│   └── openclaw.json_example
├── scripts/
│   ├── provision.sh
│   ├── sync-auth.sh
│   └── check/
├── templates/
│   └── workspace/
└── data/
```

## Troubleshooting

```bash
# Check logs
make logs

# Check status
make status

# Restart
make down && make up
```
