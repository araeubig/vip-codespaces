#!/bin/sh

set -eu
exec 2>&1

# shellcheck disable=SC2154 # set by `install.sh`
exec /usr/bin/memcached -d -u "${RUN_AS}" -m "${MEMORY_SIZE}"
