# Deployment Guide

## Overview

The Ball and Chaney Honey-Do Services website is deployed on the Spark server (`spark`) as a
sandboxed Python HTTP server behind a Tailscale Funnel.

## Prerequisites

- SSH access to the Spark server: `ssh spark`
- The website files are in `/home/cbash23/projects/ball-chaney-honey-do/` on the WSL box
- **Important:** The Spark server user is `cambash23` (home `/home/cambash23`), NOT `cbash23`

## Steps

### 1. Copy updated files to Spark

From the WSL box, copy all files to the Spark server:

```bash
scp -r /home/cbash23/projects/ball-chaney-honey-do/* spark:/home/cambash23/projects/ball-chaney-honey-do/
```

### 2. Deploy on Spark

```bash
ssh spark
cd /home/cambash23/projects/ball-chaney-honey-do
sudo bash deploy.sh
```

The `deploy.sh` script is **idempotent** — it always recreates the systemd unit file, so
re-running it picks up any changes to the sandboxing directives.

### 3. Verify deployment

```bash
# Check service is running
systemctl is-active ball-chaney-website

# Test HTTP locally
curl -sf http://localhost:8080/

# Check Tailscale Funnel is still active
tailscale funnel status
```

## Key Details

| Item | Value |
|---|---|
| Service name | `ball-chaney-website` |
| Port | 8080 |
| Public URL | `https://192-168-40-167.tail7c2155.ts.net/` |
| Spark user | `cambash23` |
| Spark home | `/home/cambash23` |

## Sandboxing

The systemd service runs with hardened sandboxing:

- **Network isolation:** `IPAddressDeny=any` + `IPAddressAllow=localhost` — only localhost communication
- **Kernel hardening:** kernel tunables, modules, control groups, logs, clock, hostname all protected
- **Process isolation:** `ProtectProc=invisible`, `RestrictNamespaces`, `LockPersonality`, `MemoryDenyWriteExecute`
- **Syscall filtering:** only `@system-service` syscalls allowed; privileged/mount/debug groups blocked
- **Filesystem:** `ProtectSystem=strict` + `ProtectHome=read-only` — only the website directory is writable

## Troubleshooting

### Service fails to start

```bash
journalctl -u ball-chaney-website -n 50
```

### Directory permission errors

Ensure the Spark user `cambash23` owns the files:

```bash
sudo chown -R cambash23:cambash23 /home/cambash23/projects/ball-chaney-honey-do
```

### Funnel not working

```bash
tailscale funnel status
# If needed: sudo tailscale funnel --bg 8080
```
