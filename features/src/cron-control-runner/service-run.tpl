#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

set -eu
exec 2>&1

# shellcheck disable=SC2269 # handled by envsubst
FPM_SOCKET="${FPM_SOCKET}"
# shellcheck disable=SC2269 # handled by envsubst
WORDPRESS_PATH="${WORDPRESS_PATH}"
# shellcheck disable=SC2269 # handled by envsubst
WP_CLI_PATH="${WP_CLI_PATH}"
# shellcheck disable=SC2269 # handled by envsubst
_REMOTE_USER="${_REMOTE_USER}"

OPTIONS=
if [ -n "${FPM_SOCKET}" ]; then
    OPTIONS="${OPTIONS} -fpm-url ${FPM_SOCKET}"
fi

if [ -n "${WORDPRESS_PATH}" ]; then
    OPTIONS="${OPTIONS} -wp-path ${WORDPRESS_PATH}"
fi

if [ -n "${WP_CLI_PATH}" ]; then
    OPTIONS="${OPTIONS} -wp-cli-path ${WP_CLI_PATH}"
fi

rm -f /var/log/cron-control-runner.log
install -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" -m 0644 /dev/null /var/log/cron-control-runner.log

# shellcheck disable=SC2086
exec chpst -u "${_REMOTE_USER}:${_REMOTE_USER}" \
    /usr/local/bin/cron-control-runner ${OPTIONS} > /var/log/cron-control-runner.log 2>&1
