#!/bin/bash

check "php-fpm is running" sudo sh -c 'sv status php-fpm | grep -E ^run:'
sudo sv stop php-fpm
check "php-fpm is stopped" sudo sh -c 'sv status php-fpm | grep -E ^down:'
sudo sv start php-fpm
check "php-fpm is running" sudo sh -c 'sv status php-fpm | grep -E ^run:'
check "Port 9000 is open" sh -c 'netstat -lnt | grep :9000 '

check "php can run" php --version
check "composer can run" composer --version

check "mailpit is running" sudo sh -c 'sv status mailpit | grep -E ^run:'
check "Port 1025 is open" sh -c 'netstat -lnt | grep :1025 '
check "Port 8025 is open" sh -c 'netstat -lnt | grep :8025 '

check "VIP CLI can run" vip --version

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
