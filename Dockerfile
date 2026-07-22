# Use the official nginx image as a base
FROM nginx:alpine

# Copy the website files to the nginx html directory
COPY . /usr/share/nginx/html

# Remove the default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]