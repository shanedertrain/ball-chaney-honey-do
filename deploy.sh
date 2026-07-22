#!/bin/bash
#
# Deployment script for Ball and Chaney Honey-Do Services website
# This script sets up a sandboxed HTTP server to serve the website
#

set -e

# Configuration
PORT=${PORT:-8080}
WEBSITE_DIR="/home/cambash23/projects/ball-chaney-honey-do"
SERVICE_NAME="ball-chaney-website"

echo "Deploying Ball and Chaney Honey-Do Services website..."
echo "Port: $PORT"
echo "Directory: $WEBSITE_DIR"

# Check if the website directory exists
if [ ! -d "$WEBSITE_DIR" ]; then
    echo "Error: Website directory does not exist!"
    exit 1
fi

# Check if port is already in use
if lsof -i :$PORT > /dev/null 2>&1; then
    echo "Warning: Port $PORT is already in use"
    echo "Killing existing process..."
    lsof -ti :$PORT | xargs kill -9 || true
    sleep 1
fi

# Create or update the systemd service file for the website
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
echo "Creating systemd service..."
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Ball and Chaney Honey-Do Services Website
After=network.target

[Service]
Type=simple
User=cambash23
WorkingDirectory=$WEBSITE_DIR
ExecStart=/usr/bin/python3 $WEBSITE_DIR/server.py
Restart=always
RestartSec=10
Environment=PORT=$PORT
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=read-only
ReadWritePaths=$WEBSITE_DIR
CapabilityBoundingSet=
AmbientCapabilities=
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectControlGroups=true
ProtectKernelLogs=true
ProtectClock=true
ProtectHostname=true
ProtectProc=invisible
RestrictNamespaces=true
RestrictRealtime=true
RestrictSUIDSGID=true
LockPersonality=true
MemoryDenyWriteExecute=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
SystemCallFilter=@system-service
SystemCallFilter=~@privileged @resources @mount @swap @module @debug @cpu-emulation
IPAddressDeny=any
IPAddressAllow=localhost

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
echo "Systemd service created and enabled"

# Start the service
echo "Starting website service..."
systemctl start "$SERVICE_NAME"

# Wait for the service to start
sleep 2

# Check if the service is running
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "✅ Website is now running on port $PORT"
    echo "URL: http://localhost:$PORT"
    echo ""
    echo "To view logs: journalctl -u $SERVICE_NAME -f"
    echo "To stop: systemctl stop $SERVICE_NAME"
    echo "To restart: systemctl restart $SERVICE_NAME"
else
    echo "❌ Failed to start website service"
    echo "Check logs: journalctl -u $SERVICE_NAME -n 50"
    exit 1
fi

# Test the website
echo ""
echo "Testing website..."
if curl -s "http://localhost:$PORT/" > /dev/null; then
    echo "✅ Website is responding correctly"
else
    echo "❌ Website is not responding"
    exit 1
fi

echo ""
echo "Deployment complete!"