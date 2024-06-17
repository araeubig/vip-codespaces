#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

source /etc/os-release
check 'crond exists' which crond
check "crontab exists" which crontab
check "crontab has setuid or setgid bit" sh -c "stat -L -c %A /usr/bin/crontab | grep -F s"

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults