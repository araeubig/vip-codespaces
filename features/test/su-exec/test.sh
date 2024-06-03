#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "su-exec exists" which su-exec

if [[ "$(id -u || true)" -eq 0 ]]; then
    check "su-exec works (user)" sh -c 'su-exec bin:daemon id -un | grep -F bin'
    check "su-exec works (group)" sh -c 'su-exec bin:daemon id -gn | grep -F daemon'
fi

reportResults
