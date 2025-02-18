#!/bin/sh

set -eu

exec 2>&1

PID_FILE=/run/nginx/nginx.pid

# shellcheck disable=SC2154
/usr/bin/install -d -o "${NGINX_USER}" -g "${NGINX_USER}" "${PID_FILE%/*}" /var/log/nginx
/usr/bin/install -d -o "${NGINX_USER}" -g "${NGINX_USER}" -m 0750 /var/lib/nginx
exec /usr/sbin/nginx -c /etc/nginx/nginx.conf -g "pid ${PID_FILE}; daemon off;"
