#!/bin/sh

set -eu
exec 2>&1

exec chpst -u "${_REMOTE_USER}:${_REMOTE_USER}" \
    /usr/local/bin/mailpit \
        --listen 127.0.0.1:8025 \
        --smtp 127.0.0.1:1025
