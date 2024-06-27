#!/bin/bash

if hash sv 2>/dev/null; then
    check "elasticsearch is running" sudo sh -c 'sv status elasticsearch | grep -E ^run:'
    sudo sv stop elasticsearch
    check "elasticsearch is stopped" sudo sh -c 'sv status elasticsearch | grep -E ^down:'
    sudo sv start elasticsearch
else
    check "elasticsearch is running" pgrep -f elasticsearch
fi

second=0
while ! curl -s 'http://127.0.0.1:9200/_cluster/health' > /dev/null && [[ "${second}" -lt 60 ]]; do
    sleep 1
    second=$((second+1))
done
status="$(curl -s 'http://127.0.0.1:9200/_cluster/health?wait_for_status=yellow&timeout=60s' | jq -r .status || true)"
check "Elasticsearch came online" test "${status}" == 'green' -o "${status}" = 'yellow'

if hash sv 2>/dev/null; then
    sudo sv stop elasticsearch
else
    sudo pkill -TERM -e -o -f /usr/bin/elasticsearch
fi

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
