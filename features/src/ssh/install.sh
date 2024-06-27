#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"

if [ "${ENABLED:-}" = "true" ]; then
    echo '(*) Installing OpenSSH server...'

    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"
    PRIVSEP_DIR=

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y --no-install-recommends openssh-server
            apt-get clean
            rm -rf /var/lib/apt/lists/*
            update-rc.d -f ssh remove
            PRIVSEP_DIR=/run/sshd
        ;;

        "alpine")
            apk add --no-cache openssh-server
            rm -f /etc/conf.d/sshd /etc/init.d/sshd
            PRIVSEP_DIR=/var/empty
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
    esac

    install -D -d -m 0555 -o root -g root "${PRIVSEP_DIR}"
    install -d -m 0755 -o root -g root /etc/service
    install -D -m 0755 -o root -g root service-run /etc/sv/openssh/run
    ln -sf /etc/sv/openssh /etc/service/openssh

    if [ "${_REMOTE_USER}" = 'root' ]; then
        echo 'PermitRootLogin=yes' > /etc/ssh/sshd_config.d/permit_root_login.conf
    fi

    echo 'Done!'
fi
