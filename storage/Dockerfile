FROM httpd:2.4-alpine
# Storage only: Apache serves the license-plate photos as static files.
# No photos are baked into the image - they live ONLY in the named volume
# "plates-data", mounted at /usr/local/apache2/htdocs/images (see docker-compose.yml).
# Make sure the folder exists and is readable for Apache before the volume is mounted.
RUN mkdir -p /usr/local/apache2/htdocs/images
# Apache's default config already enables directory listing (Options Indexes).
EXPOSE 80
