#!/bin/sh

set -eu
exec 2>&1

# shellcheck disable=SC2154
MY_UID="$(id -u "${_REMOTE_USER}")"
MY_GID="$(id -g "${_REMOTE_USER}")"

exec setpriv --reuid="${MY_UID}" --regid="${MY_GID}" --inh-caps=-all --init-groups \
    /usr/local/bin/mailpit \
        --listen 127.0.0.1:8025 \
        --smtp 127.0.0.1:1025 &
