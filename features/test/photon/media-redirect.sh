#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

source ./checks.sh

redirect_url="$(curl -s -w '%{redirect_url}' http://localhost/wp-content/uploads/xxx.png -o /dev/null)"
check "media-redirect; redirect URL is set" test "${redirect_url}" = "http://local.invalid/wp-content/uploads/xxx.png"

reportResults
