#!/bin/sh

XDEBUG_MODE=off
export XDEBUG_MODE

if [ -f /etc/conf.d/wordpress ]; then
    # shellcheck source=/dev/null
    . /etc/conf.d/wordpress
fi

: "${WP_DOMAIN:=localhost}"
: "${WP_MULTISITE:=""}"
: "${WP_MULTISITE_TYPE:=subdirectory}"
: "${WP_PERSIST_UPLOADS:=""}"

if [ "${CODESPACES:-}" = 'true' ] && [ "${CLOUDENV_ENVIRONMENT_ID:-}" = 'null' ] && [ -n "${GITHUB_TOKEN}" ]; then
    echo "Prebuild detected, skipping WordPress setup"
    exit 0
fi

if [ -n "${CODESPACE_NAME}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}" ]; then
    WP_DOMAIN="${CODESPACE_NAME}-80.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi

db_host=127.0.0.1
db_admin_user=root
wp_url="http://${WP_DOMAIN}"
wp_title="WordPress VIP Development Site"

if [ -n "${WP_MULTISITE}" ]; then
    multisite_domain="${WP_DOMAIN}"
    multisite_type="${WP_MULTISITE_TYPE}"
    if [ -n "${CODESPACE_NAME}" ]; then
        multisite_type="subdirectories"
    fi
else
    multisite_domain=
    multisite_type=
fi

MY_UID="$(id -u)"
MY_GID="$(id -g)"

if [ 0 -eq "${MY_UID}" ]; then
    export WP_CLI_ALLOW_ROOT=1
fi

if [ -n "${RepositoryName}" ]; then
    base=/workspaces/${RepositoryName}
else
    base=$(pwd)
fi

for i in client-mu-plugins images languages plugins themes; do
    if [ -e "${base}/${i}" ]; then
        sudo rm -rf "/wp/wp-content/${i}"
    fi
done

if [ -e "${base}/vip-config" ]; then
    sudo rm -rf /wp/vip-config
fi

sudo chown "${MY_UID}:${MY_GID}" /wp/* /wp/wp-content/*

for i in client-mu-plugins images languages plugins themes; do
    if [ -e "${base}/${i}" ]; then
        ln -sf "${base}/${i}" "/wp/wp-content/${i}"
    fi
done

if [ -e "${base}/vip-config" ]; then
    ln -sf "${base}/vip-config" "/wp/vip-config"
fi

if [ -n "${WP_PERSIST_UPLOADS}" ] && [ -d /workspaces ]; then
    sudo install -d -o "${MY_UID}" -g "${MY_GID}" -m 0755 /workspaces/uploads
    ln -sf /workspaces/uploads /wp/wp-content/uploads
else
    install -d -m 0755 /wp/wp-content/uploads
fi

export WP_USERNAME="wordpress"
export WP_PASSWORD="wordpress"
export WP_DATABASE="wordpress"
export WP_DBHOST="${db_host}"

# shellcheck disable=SC2016
envsubst '$WP_USERNAME $WP_PASSWORD $WP_DATABASE $WP_DBHOST' < /usr/share/wordpress/wp-config.php.tpl > /wp/config/wp-config.php
if [ -n "${multisite_domain}" ]; then
    wp config set WP_ALLOW_MULTISITE true --raw  --config-file=/wp/config/wp-config.php
    wp config set MULTISITE true --raw  --config-file=/wp/config/wp-config.php
    wp config set DOMAIN_CURRENT_SITE "${multisite_domain}"  --config-file=/wp/config/wp-config.php
    wp config set PATH_CURRENT_SITE /  --config-file=/wp/config/wp-config.php
    wp config set SITE_ID_CURRENT_SITE 1 --raw  --config-file=/wp/config/wp-config.php
    wp config set BLOG_ID_CURRENT_SITE 1 --raw  --config-file=/wp/config/wp-config.php
    if [ "${multisite_type}" != "subdomain" ]; then
        wp config set SUBDOMAIN_INSTALL false --raw --config-file=/wp/config/wp-config.php
    else
        wp config set SUBDOMAIN_INSTALL true --raw --config-file=/wp/config/wp-config.php
    fi
    wp config set SUNRISE true --raw  --config-file=/wp/config/wp-config.php
fi
wp config shuffle-salts --config-file=/wp/config/wp-config.php

echo "Waiting for MySQL to come online..."
second=0
while ! mysqladmin ping -u "${db_admin_user}" -h "${db_host}" --silent && [ "${second}" -lt 60 ]; do
    sleep 1
    second=$((second+1))
done
if ! mysqladmin ping -u "${db_admin_user}" -h "${db_host}" --silent; then
    echo "ERROR: mysql has failed to come online"
    exit 1;
fi

{
    echo "CREATE USER IF NOT EXISTS '${WP_USERNAME}'@'localhost' IDENTIFIED BY '${WP_PASSWORD}';";
    echo "CREATE USER IF NOT EXISTS 'netapp'@'localhost' IDENTIFIED BY '${WP_PASSWORD}';";
    echo "CREATE DATABASE IF NOT EXISTS ${WP_DATABASE};"
    echo "GRANT ALL ON ${WP_DATABASE}.* TO '${WP_USERNAME}'@'localhost';"
    echo "GRANT ALL ON ${WP_DATABASE}.* TO 'netapp'@'localhost';"
} | mysql -h "${db_host}" -u "${db_admin_user}"

wp cache flush --skip-plugins --skip-themes
echo "Checking for WordPress installation..."
if ! wp core is-installed --skip-plugins --skip-themes >/dev/null 2>&1; then
    echo "No installation found, installing WordPress..."

    wp db clean --yes 2> /dev/null
    if [ -n "${multisite_domain}" ]; then
        if [ "${multisite_type}" = "subdomain" ]; then
            type="--subdomains"
        else
            type=""
        fi
        # shellcheck disable=SC2248,SC2086 # see https://github.com/Automattic/vip-codespaces/issues/86
        wp core multisite-install \
            --path=/wp \
            --url="${wp_url}" \
            --title="${wp_title}" \
            --admin_user="vipgo" \
            --admin_email="vip@localhost.local" \
            --admin_password="password" \
            --skip-email \
            --skip-plugins \
            --skip-themes \
            ${type} \
            --skip-config
    else
        wp core install \
            --path=/wp \
            --url="${wp_url}" \
            --title="${wp_title}" \
            --admin_user="vipgo" \
            --admin_email="vip@localhost.local" \
            --admin_password="password" \
            --skip-email \
            --skip-plugins \
            --skip-themes
    fi

    wp user add-cap 1 view_query_monitor
    wp rewrite structure '/%postname%/'

    run-parts /var/lib/wordpress/postinstall.d
else
    echo "WordPress is already installed"
fi

if [ ! -f "${HOME}/.local/share/vip-codespaces/login/010-wplogin.sh" ]; then
    install -D -d -m 0755 "${HOME}/.local/share/vip-codespaces/login"
    export WP_URL="${wp_url}"
    # shellcheck disable=SC2016
    envsubst '$WP_URL' < /usr/share/wordpress/010-wplogin.tpl > "${HOME}/.local/share/vip-codespaces/login/010-wplogin.sh"
fi

exit 0
