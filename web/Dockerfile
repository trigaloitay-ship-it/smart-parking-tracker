FROM nginx:1.27-alpine
# Replace the default site with our reverse-proxy config
COPY nginx.conf /etc/nginx/conf.d/default.conf
# The guard dashboard
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
