#!/bin/sh

set -e
exec 2>&1

# shellcheck disable=SC2312
ES_JAVA_HOME="$(dirname "$(dirname "$(readlink -f /usr/bin/java)")")"
ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ ${ES_JAVA_OPTS:-}"
export ES_JAVA_HOME ES_JAVA_OPTS

# shellcheck disable=SC2154 # ES_USER and ES_DATADIR are substituted by `install.sh`.
chown -R "${ES_USER}:${ES_USER}" "${ES_DATADIR}" /usr/share/elasticsearch/config /usr/share/elasticsearch/logs /usr/share/elasticsearch/tmp /usr/share/elasticsearch/plugins
# shellcheck disable=SC2154
if [ -x /sbin/chpst ]; then
    exec /sbin/chpst -u "${ES_USER}:root" /usr/bin/elasticsearch > /dev/null &
else
    exec /sbin/su-exec "${ES_USER}:root" /usr/bin/elasticsearch > /dev/null &
fi
