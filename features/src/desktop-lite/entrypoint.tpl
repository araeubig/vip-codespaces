#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

set -eu

# shellcheck disable=SC2154
HOME_DIR="$(getent passwd "${_REMOTE_USER}" | cut -d: -f6)"
if [ -f "${HOME_DIR}/.vnc/passwd" ]; then
    AUTH_OPTS="-rfbauth ${HOME_DIR}/.vnc/passwd"
else
    AUTH_OPTS="-SecurityTypes None"
fi

# shellcheck disable=SC2154,SC2086
su -s /bin/sh -c "/usr/bin/Xtigervnc -geometry \"${VNC_GEOMETRY}\" -listen tcp -ac ${AUTH_OPTS} -AlwaysShared -AcceptKeyEvents -AcceptPointerEvents -SendCutText -AcceptCutText :0" "${_REMOTE_USER}" &
DISPLAY=:0 su -s /bin/sh -c '/usr/bin/openbox' "${_REMOTE_USER}" &
su -s /bin/sh -c '/usr/local/bin/easy-novnc -a :5800 -h 127.0.0.1 --no-url-password' "${_REMOTE_USER}" &
