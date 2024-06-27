#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

for i in /usr/share/webapps/phpmyadmin /etc/phpmyadmin /etc/conf.d /usr/share/webapps/phpmyadmin/tmp; do
    check "${i} exists" test -d "${i}"
done

for i in /etc/conf.d/phpmyadmin-password /etc/phpmyadmin/config.inc.php; do
    check "${i} exists" test -f "${i}"
done

for i in /etc/nginx/conf.extra/.htpasswd-pma "${HOME}/.local/share/vip-codespaces/login/050-phpmyadmin.sh" /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf; do
    check "${i} does not exist" test \! -e "${i}"
done

# shellcheck disable=SC2043
for i in /usr/share/webapps/phpmyadmin/config.inc.php; do
    check "${i} is a symlink" test -L "${i}"
done

reportResults
