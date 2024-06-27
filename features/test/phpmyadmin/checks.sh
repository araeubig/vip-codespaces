#!/bin/bash

check "Port 81 is open" sh -c 'netstat -lnt | grep :80 '

for i in /usr/share/webapps/phpmyadmin /etc/phpmyadmin /etc/nginx/conf.extra /etc/conf.d /usr/share/webapps/phpmyadmin/tmp; do
    check "${i} exists" test -d "${i}"
done

for i in /etc/conf.d/phpmyadmin-password /etc/nginx/conf.extra/.htpasswd-pma "${HOME}/.local/share/vip-codespaces/login/050-phpmyadmin.sh" /etc/phpmyadmin/config.inc.php /etc/nginx/sites-available/phpmyadmin.conf; do
    check "${i} exists" test -f "${i}"
done

for i in /usr/share/webapps/phpmyadmin/config.inc.php /etc/nginx/sites-enabled/phpmyadmin.conf; do
    check "${i} is a symlink" test -L "${i}"
done

pass="$(cat /etc/conf.d/phpmyadmin-password)"
check "Basic Auth is required" sh -c "curl -s -w '%{response_code}' http://localhost:81 | grep -F 401"
check "phpMyAdmin works" sh -c "curl -s -w '%{response_code}' -u \"vipgo:${pass}\" http://localhost:81 | grep -F 200"

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
