#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

source ./checks.sh

check "/workspaces/es-data exists" test -d /workspaces/es-data

MY_NAME="$(id -un)"

check "/workspaces/es-data is owned by ${MY_NAME}" test "$(stat -c %U /workspaces/es-data || true)" = "${MY_NAME}"

reportResults
