#!/bin/bash

check "memcached is running" sudo sh -c 'sv status memcached | grep -E ^run:'
sudo sv stop memcached
check "memcached is stopped" sudo sh -c 'sv status memcached | grep -E ^down:'
sudo sv start memcached
check "memcached is running" sudo sh -c 'sv status memcached | grep -E ^run:'

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
