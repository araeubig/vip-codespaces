#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "memcached exists" which memcached
if [[ -d /etc/sv ]]; then
    check "/etc/sv/memcached/run exists and is executable" test -x /etc/sv/memcached/run
    check "/etc/service/memcached is a symlink" test -L /etc/service/memcached
fi

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
