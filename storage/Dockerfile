# Storage server: a small Apache that ONLY serves the camera photos

# Start from a ready-made Apache on Alpine Linux (small image)
FROM httpd:2.4-alpine

# No photos are copied into the image - they live only in the named volume "plates-data",
# which docker-compose mounts on /usr/local/apache2/htdocs/images.
# (Apache's default config already shows a file list for folders - the dashboard reads it.)

# Apache listens on port 80 inside the container
EXPOSE 80
