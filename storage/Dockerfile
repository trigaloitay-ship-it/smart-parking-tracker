FROM httpd:2.4-alpine
# Seed images: copied into the named volume on its FIRST creation
COPY images/ /usr/local/apache2/htdocs/images/
# Apache's default config already enables directory listing (Options Indexes)
EXPOSE 80
