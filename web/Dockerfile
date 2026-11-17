# Web server (dashboard): a small Nginx that serves our HTML page

# Start from a ready-made Nginx on Alpine Linux (small image)
FROM nginx:1.27-alpine

# Our config: serve the page + proxy /storage/ to the storage container
COPY nginx.conf /etc/nginx/conf.d/default.conf

# The guard dashboard
COPY index.html /usr/share/nginx/html/index.html

# Nginx listens on port 80 inside the container
EXPOSE 80
