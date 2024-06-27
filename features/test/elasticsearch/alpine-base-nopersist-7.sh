#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

source ./checks.sh

check "/usr/share/elasticsearch/data exists" test -d /usr/share/elasticsearch/data

MY_UID="$(id -u)"
MY_NAME="$(id -un)"

if [[ "${MY_UID}" = "0" ]]; then
    check "/usr/share/elasticsearch/data is owned by elasticsearch" test "$(stat -c %U /usr/share/elasticsearch/data || true)" = "elasticsearch"
else
    check "/usr/share/elasticsearch/data is owned by ${MY_NAME}" test "$(stat -c %U /usr/share/elasticsearch/data || true)" = "${MY_NAME}"
fi

reportResults
