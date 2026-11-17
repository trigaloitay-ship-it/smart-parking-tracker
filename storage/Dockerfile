FROM httpd:2.4-alpine
# Storage only: Apache serves the license-plate photos as static files.
# The photos are NOT baked into the image - docker-compose mounts
# ./storage/images into /usr/local/apache2/htdocs/images at runtime.
# Apache's default config already enables directory listing (Options Indexes).
EXPOSE 80
