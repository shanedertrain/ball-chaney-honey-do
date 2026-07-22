#!/bin/bash
#
# Deployment script for Ball and Chaney Honey-Do Services website
# This script sets up a sandboxed HTTP server to serve the website
#

set -e

# Configuration
PORT=${PORT:-8080}
WEBSITE_DIR="/home/cbash23/projects/ball-chaney-honey-do"
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

# Create a systemd service file for the website
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if [ ! -f "$SERVICE_FILE" ]; then
    echo "Creating systemd service..."
    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Ball and Chaney Honey-Do Services Website
After=network.target

[Service]
Type=simple
User=cbash23
WorkingDirectory=$WEBSITE_DIR
ExecStart=/usr/bin/python3 $WEBSITE_DIR/server.py
Restart=always
RestartSec=10
Environment=PORT=$PORT
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=$WEBSITE_DIR
CapabilityBoundingSet=
AmbientCapabilities=

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"
    echo "Systemd service created and enabled"
fi

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