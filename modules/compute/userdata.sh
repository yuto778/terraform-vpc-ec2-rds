#!/bin/bash
set -eux
# nginx をインストールして Listen
amazon-linux-extras install -y nginx1
systemctl enable --now nginx

# シンプルなヘルス用ページ
echo ok >/usr/share/nginx/html/health.html