#!/bin/bash
#starting php-fpm
mkdir -p /run/php
/usr/sbin/php-fpm7
chown -R nginx:nginx /run/php/php7.4-fpm.sock
#Nginx Laravel Site Template
envsubst <  /etc/nginx/site-template-nginx.conf > /etc/nginx/conf.d/default.conf
mkdir -p /run/nginx
chown -R nginx:nginx /run/nginx/
nginx -g 'pid /run/nginx/nginx.pid;'
tail -f /dev/null
