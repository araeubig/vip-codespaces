#!/vin/bash

check 'php-fpm is running' sudo sh -c 'sv status php-fpm | grep -E ^run:'
check 'mailpit is running' sudo sh -c 'sv status mailpit | grep -E ^run:'
check 'memcached is running' sudo sh -c 'sv status memcached | grep -E ^run:'
check 'mysql is running' sudo sh -c 'sv status mariadb | grep -E ^run:'
check 'nginx is running' sudo sh -c 'sv status nginx | grep -E ^run:'
check 'elasticsearch is running' sudo sh -c 'sv status elasticsearch | grep -E ^run:'
check 'cron is running' sudo sh -c 'sv status cron | grep -E ^run:'
check 'syslog is running' sudo sh -c 'sv status syslog | grep -E ^run:'

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
