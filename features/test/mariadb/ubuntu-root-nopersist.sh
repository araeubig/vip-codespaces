#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

source ./checks.sh

check "/var/lib/mysql exists" test -d /var/lib/mysql
check "/var/lib/mysql is owned by mysql" test "$(stat -c %u /var/lib/mysql || true)" = "$(id -u mysql || true)"

reportResults