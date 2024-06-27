#!/bin/bash

check "cron-control-runner is running" sudo sh -c 'sv status cron-control-runner | grep -E ^run:'
sudo sv stop cron-control-runner
check "cron-control-runner is stopped" sudo sh -c 'sv status cron-control-runner | grep -E ^down:'
rm -f /var/log/cron-control-runner.log
sudo sv start cron-control-runner
check "cron-control-runner is running" sudo sh -c 'sv status cron-control-runner | grep -E ^run:'

check "cron-control-runner logs events" sh -c 'grep -qF "cron runner has started all processes" /var/log/cron-control-runner.log'

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
