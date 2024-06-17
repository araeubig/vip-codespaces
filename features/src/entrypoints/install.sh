#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

install -D -d -m 0755 -o root -g root /var/lib/entrypoint.d
install -m 0755 -o root -g root entrypoint-runner /usr/local/bin/entrypoint-runner
