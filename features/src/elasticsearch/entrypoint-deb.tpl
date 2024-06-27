#!/bin/sh

set -e
exec 2>&1

# shellcheck disable=SC2154 # ES_USER and ES_DATADIR are substituted by `install.sh`.
chown -R "${ES_USER}:${ES_USER}" "${ES_DATADIR}" /usr/share/elasticsearch/config /usr/share/elasticsearch/logs /usr/share/elasticsearch/tmp /usr/share/elasticsearch/plugins
# shellcheck disable=SC2154
ES_UID="$(id -u "${ES_USER}")"
ES_GID="$(id -g root)"
exec setpriv --reuid="${ES_UID}" --regid="${ES_GID}" --inh-caps=-all --init-groups /usr/bin/elasticsearch > /dev/null &
