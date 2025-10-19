FROM openresty/openresty:alpine-fat

LABEL maintainer="legal_api"

WORKDIR /app

# Install build dependencies needed for Lapis and its native modules
RUN apk add --no-cache \
    openssl-dev \
    gcc \
    musl-dev \
    make \
    sqlite-dev

# Install Lapis and dependencies using LuaRocks (already included in alpine-fat)
# The alpine-fat image includes LuaRocks at /usr/local/openresty/luajit/bin/luarocks
RUN /usr/local/openresty/luajit/bin/luarocks install lapis && \
    /usr/local/openresty/luajit/bin/luarocks install busted && \
    /usr/local/openresty/luajit/bin/luarocks install lsqlite3

# Clean up build dependencies to reduce image size (optional, comment out for faster rebuilds)
# RUN apk del gcc musl-dev make

# Copy application files
COPY . /app

# Create .dockerjunk directory for logs and temporary files
RUN mkdir -p /app/.dockerjunk/logs \
    /app/.dockerjunk/client_body_temp \
    /app/.dockerjunk/proxy_temp \
    /app/.dockerjunk/fastcgi_temp \
    /app/.dockerjunk/uwsgi_temp \
    /app/.dockerjunk/scgi_temp

# Mount nginx.conf will be done via docker-compose volume
# The application files are in /app and accessible to OpenResty

EXPOSE 80

ENV PATH="/usr/local/openresty/bin:/usr/local/openresty/nginx/sbin:${PATH}"
ENV LAPIS_ENV=development

# Start openresty in foreground (daemon off is already in nginx.conf)
CMD ["openresty", "-p", "/app/", "-c", "nginx.conf"]
