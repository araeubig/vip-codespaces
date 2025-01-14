#!/bin/sh

if [ "${CODESPACES:-}" = 'true' ] && [ "${CLOUDENV_ENVIRONMENT_ID:-}" = 'null' ] && [ -n "${GITHUB_TOKEN}" ]; then
    echo "Prebuild detected, skipping WordPress setup"
    exit 0
fi

if [ -n "${CODESPACE_NAME}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}" ]; then
    : "${EXTERNAL_PORT:=80}"
    WP_DOMAIN="${CODESPACE_NAME}-${EXTERNAL_PORT}.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
else
    WP_DOMAIN="localhost"
fi

echo "Checking out submodules..."
[ -f .gitmodules ] && git submodule update --init --recursive --single-branch --depth=1

[ -f composer.json ] && composer install

echo "Waiting for MySQL to come online..."
second=0
while ! mysqladmin ping -uroot -ppassword -hdatabase --silent && [ "${second}" -lt 60 ]; do
    sleep 1
    second=$((second+1))
done
if ! mysqladmin ping -uroot -ppassword -hdatabase --silent; then
    echo "ERROR: mysql has failed to come online"
    exit 1;
fi

sudo -u www-data -E wp core install \
    --path=/var/www/html \
    --url="http://${WP_DOMAIN}" \
    --title="WordPress" \
    --admin_user="vipgo" \
    --admin_email="vip@localhost.local" \
    --admin_password="password" \
    --skip-email \
    --skip-plugins \
    --skip-themes

if [ -n "${NVM_DIR}" ]; then
    # shellcheck source=/dev/null
    . "${NVM_DIR}/nvm.sh" && nvm install --lts
fi

[ -f package.json ] && npm i
exit 0
