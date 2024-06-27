#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "/usr/local/bin/cron-control-runner exists and is executable" test -x /usr/local/bin/cron-control-runner
check "/usr/local/bin/wp exists and is executable" test -x /usr/local/bin/wp
check "/usr/local/bin/wp.phar exists and is a symlink" test -L /usr/local/bin/wp.phar
check "/var/wpvip/fpm-cron-runner.php exists" test -f /var/wpvip/fpm-cron-runner.php

if [[ -d /etc/sv ]]; then
    check "/etc/sv/cron-control-runner/run exists and is executable" test -x /etc/sv/cron-control-runner/run
    check "/etc/service/cron-control-runner exists and is a symlink" test -L /etc/service/cron-control-runner
fi
