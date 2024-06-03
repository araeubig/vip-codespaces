#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

# shellcheck disable=SC2016
check "PAGER is set" sh -c 'echo "${PAGER}" | grep -q "less"'
check "${HOME}/.local/share/vip-codespaces exists" test -d "${HOME}/.local/share/vip-codespaces"
check "${HOME}/.local/share/vip-codespaces/login exists" test -d "${HOME}/.local/share/vip-codespaces/login"
check "${HOME}/.local/share/vip-codespaces/login/001-welcome.sh exists" test -f "${HOME}/.local/share/vip-codespaces/login/001-welcome.sh"

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
