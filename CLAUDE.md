# CLAUDE.md — Ball and Chaney Honey-Do Services Website

## Project

A simple, professional static website for Ball and Chaney Honey-Do Services (lawn care and handyman
business in Slidell, Louisiana). Built with HTML, CSS, and a sandboxed Python HTTP server.

## Files

- `index.html` — Home page
- `services.html` — Services page
- `contact.html` — Contact page
- `styles.css` — CSS stylesheet
- `server.py` — Sandboxed HTTP server (directory traversal protection, file type allowlist)
- `deploy.sh` — Deployment script (creates systemd service with hardened sandboxing)
- `Dockerfile` / `docker-compose.yml` — Docker deployment alternative
- `nginx.conf` — Nginx configuration alternative
- `README.md` — Project overview and sandboxing options
- `DEPLOYMENT.md` — Detailed deployment guide for the Spark server

## Deployment

**Primary: GitHub Pages** — public repo `shanedertrain/ball-chaney-honey-do`, deploys
automatically on `git push` (branch `master`, root). Public URL:
`https://shanedertrain.github.io/ball-chaney-honey-do/`

**Secondary: Spark server.** See **DEPLOYMENT.md** for full instructions. Quick summary:

```bash
scp -r /home/cbash23/projects/ball-chaney-honey-do/* spark:/home/cambash23/projects/ball-chaney-honey-do/
ssh spark
cd /home/cambash23/projects/ball-chaney-honey-do
sudo bash deploy.sh
```

**Key details:**
- Spark user is `cambash23` (home `/home/cambash23`), NOT `cbash23`
- Service name: `ball-chaney-website` on port 8080
- Public URL: `https://192-168-40-167.tail7c2155.ts.net/`
- `deploy.sh` is idempotent — safe to re-run
