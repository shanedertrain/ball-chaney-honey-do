# Ball and Chaney Honey-Do Services Website

A simple, professional website for Ball and Chaney Honey-Do Services, a lawn care and handyman business based in Slidell, Louisiana.

## Project Structure

```
ball-chaney-honey-do/
├── index.html          # Home page
├── services.html       # Services page
├── contact.html        # Contact page
├── styles.css          # CSS stylesheet
└── README.md           # This file
```

## Features

- Responsive design that works on mobile and desktop
- Clean, professional appearance with lawn care theme colors
- Clear emphasis on Facebook as the primary contact method
- Service pages highlighting lawn mowing, yard work, and pool setup
- Location information for Slidell, Louisiana
- Links to their Facebook page throughout

## Deployment

This website is designed to be served as static content. To deploy:

1. Copy the files to your web server's document root
2. Configure your web server to serve these files
3. Ensure the server is properly secured and sandboxed from the rest of the system

## Sandboxing Instructions

For maximum security, this website should be served in a sandboxed environment:

### Option 1: Docker Container (Recommended)
```bash
docker run -d \
  --name ball-chaney-website \
  -p 8080:80 \
  -v $(pwd):/usr/share/nginx/html:ro \
  --read-only \
  --tmpfs /tmp \
  nginx:alpine
```

### Option 2: Simple HTTP Server with Chroot
```bash
# Create a chroot environment
mkdir -p /var/www/ball-chaney
cp *.html *.css /var/www/ball-chaney/
# Serve with a simple HTTP server
cd /var/www/ball-chaney && python3 -m http.server 8080
```

### Option 3: Nginx with Restricted Permissions
Configure nginx to serve only files from the project directory, with no access to the rest of the filesystem.

## Contact

For questions about this website, contact the developer.
For service inquiries, please visit the business's Facebook page: https://www.facebook.com/share/196xAoV2Mr/