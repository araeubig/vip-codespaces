#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

set -eu
exec 2>&1

# shellcheck disable=SC2154
HOME_DIR="$(getent passwd "${_REMOTE_USER}" | cut -d: -f6)"
if [ -f "${HOME_DIR}/.vnc/passwd" ]; then
    AUTH_OPTS="-rfbauth ${HOME_DIR}/.vnc/passwd"
else
    AUTH_OPTS="-SecurityTypes None"
fi

# shellcheck disable=SC2154
export USER="${_REMOTE_USER}"
export LOGNAME="${USER}"
# shellcheck disable=SC2155
export HOME="$(getent passwd "${USER}" | cut -d: -f6)"

# shellcheck disable=SC2154,SC2086
exec chpst -u "${USER}:${USER}" \
    /usr/bin/Xtigervnc -geometry "${VNC_GEOMETRY}" -listen tcp -ac ${AUTH_OPTS} -AlwaysShared -AcceptKeyEvents -AcceptPointerEvents -SendCutText -AcceptCutText :0
