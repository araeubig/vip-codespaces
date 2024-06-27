#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
: "${BRANCH:=staging}"
: "${DEVELOPMENT_MODE:=false}"

if [ "${ENABLED}" != "false" ]; then
    echo '(*) Installing VIP Go mu-plugins...'

    PACKAGES=""
    if ! hash git >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} git"
    fi

    if ! hash update-ca-certificates >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} ca-certificates"
    fi

    if ! hash rsync >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} rsync"
    fi

    # shellcheck source=/dev/null
    . /etc/os-release
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            if [ -n "${PACKAGES}" ]; then
                apt-get update
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES}
                update-rc.d -f rsync remove
                apt-get clean
                rm -rf /var/lib/apt/lists/*
            fi
        ;;

        "alpine")
            if [ -n "${PACKAGES}" ]; then
                # shellcheck disable=SC2086
                apk add --no-cache ${PACKAGES}
            fi
        ;;

        *)
            echo "Unsupported distribution: ${ID_LIKE}"
            exit 1
        ;;
    esac

    install -D -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" /wp/wp-content/mu-plugins

    git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/Automattic/vip-go-mu-plugins.git /tmp/mu-plugins --branch "${BRANCH}" --single-branch -j4
    git clone --depth=1 https://github.com/Automattic/vip-go-mu-plugins-ext.git /tmp/mu-plugins-ext --single-branch
    if [ "${DEVELOPMENT_MODE}" != 'true' ]; then
        rsync -a /tmp/mu-plugins/ /tmp/mu-plugins-ext/ /wp/wp-content/mu-plugins --exclude-from="/tmp/mu-plugins/.dockerignore" --exclude-from="/tmp/mu-plugins-ext/.dockerignore"
        find /wp/wp-content/mu-plugins \( -name .svn -o -name .github -o -name ".git*" \) -type d -exec rm -rfv {} \; 2> /dev/null
    else
        rsync -a /tmp/mu-plugins/ /tmp/mu-plugins-ext/ /wp/wp-content/mu-plugins
    fi

    rm -rf /tmp/mu-plugins /tmp/mu-plugins-ext

    chown -R "${_REMOTE_USER}:${_REMOTE_USER}" /wp/wp-content/mu-plugins
    echo 'Done!'
fi
