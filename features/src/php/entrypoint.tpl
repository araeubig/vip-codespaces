#!/bin/sh

set -eu
exec 2>&1

# shellcheck disable=SC2154
PHP_USER="${_REMOTE_USER}"

touch /var/log/php-fpm/php-fpm.log
chown "root:${PHP_USER}" /var/log/php-fpm/php-fpm.log
chmod a+r /var/log/php-fpm/php-fpm.log

exec /usr/sbin/php-fpm --daemonize
