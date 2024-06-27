#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

source ./checks.sh

check "/var/lib/mysql does not exists" test ! -d /var/lib/mysql
check "/workspaces/mysql-data exists" test -d /workspaces/mysql-data
check "/workspaces/mysql-data is owned by $(id -un || true)" test "$(stat -c %u /workspaces/mysql-data || true)" = "$(id -u || true)"

reportResults
