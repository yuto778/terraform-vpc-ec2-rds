#!/bin/bash
set -eux

# 1) Docker (Amazon Linux 2)
amazon-linux-extras install -y docker
systemctl enable --now docker

# 2) 固定 200 OK ページ
echo "ok" >/tmp/health.html

# 3) Nginx コンテナ
docker run --name nginx -d \
  --restart unless-stopped \
  -p 80:80 \
  -v /tmp/health.html:/usr/share/nginx/html/health.html:ro,Z \
  nginx:1.25-alpine