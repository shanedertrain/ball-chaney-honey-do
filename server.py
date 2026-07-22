#!/usr/bin/env python3
"""
Sandboxed HTTP server for Ball and Chaney Honey-Do Services website.

This server is configured to:
1. Only serve files from the website directory
2. Run in a restricted environment
3. Prevent access to files outside the website directory
4. Use a non-privileged port
"""

import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler
from socketserver import ThreadingMixIn
import threading

# Change to the website directory
WEBSITE_DIR = os.path.dirname(os.path.abspath(__file__))
os.chdir(WEBSITE_DIR)

class SandboxedHTTPRequestHandler(SimpleHTTPRequestHandler):
    """HTTP request handler that only serves files from the website directory."""
    
    def __init__(self, *args, **kwargs):
        # Restrict to the current directory
        super().__init__(*args, directory=WEBSITE_DIR, **kwargs)
    
    def log_message(self, format, *args):
        # Log to stderr for monitoring
        sys.stderr.write("%s - - [%s] %s\n" %
                         (self.address_string(),
                          self.log_date_time_string(),
                          format % args))
    
    def do_GET(self):
        # Handle root path - serve index.html
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        
        # Only allow GET requests for specific file types
        allowed_extensions = ['.html', '.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.ico']
        if not any(self.path.endswith(ext) for ext in allowed_extensions):
            self.send_error(403, "File type not allowed")
            return
        
        # Prevent directory traversal
        if '..' in self.path:
            self.send_error(403, "Access denied")
            return
            
        super().do_GET()

class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in separate threads for better performance."""
    daemon_threads = True

def main():
    PORT = int(os.environ.get('PORT', 8080))
    
    server = ThreadedHTTPServer(('0.0.0.0', PORT), SandboxedHTTPRequestHandler)
    
    print(f"Serving Ball and Chaney Honey-Do Services website on port {PORT}")
    print(f"Website directory: {WEBSITE_DIR}")
    print("Press Ctrl+C to stop the server")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server...")
        server.shutdown()

if __name__ == '__main__':
    main()