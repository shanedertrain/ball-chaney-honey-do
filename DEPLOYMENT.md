# Deployment Guide

## Primary hosting: GitHub Pages (free)

The site is hosted on GitHub Pages from the public repo
`https://github.com/shanedertrain/ball-chaney-honey-do` (branch `master`, root).

**Public URL:** https://shanedertrain.github.io/ball-chaney-honey-do/

To deploy changes:

```bash
git add -A && git commit -m "..." && git push
```

Pages rebuilds automatically on push (takes ~1 minute). A custom domain (e.g.
ballandchaneyhoneydo.com, ~$10-12/yr) can be pointed at it later via repo Settings → Pages.

## Secondary hosting: Spark server (self-hosted)

The site is also deployed on the Spark server (`spark`) as a sandboxed Python HTTP server
behind a Tailscale Funnel.

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
