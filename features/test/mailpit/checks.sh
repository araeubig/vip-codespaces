#!/bin/bash

if hash sv >/dev/null 2>&1; then
    check "mailpit is running" sudo sh -c 'sv status mailpit | grep -E ^run:'
    sudo sv stop mailpit
    check "mailpit is stopped" sudo sh -c 'sv status mailpit | grep -E ^down:'
    sudo sv start mailpit
    check "mailpit is running" sudo sh -c 'sv status mailpit | grep -E ^run:'
else
    check "mailpit is running" pgrep mailpit
fi

check "Port 1025 is open" sh -c 'netstat -lnt | grep :1025 '
check "Port 8025 is open" sh -c 'netstat -lnt | grep :8025 '

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
