#!/bin/bash

DIRS="/etc/conf.d /etc/wp-cli /usr/share/wordpress /var/lib/wordpress/postinstall.d /wp"
for i in ${DIRS}; do
    check "Directory ${i} exists" test -d "${i}"
done

EXECUTABLES="/usr/local/bin/setup-wordpress.sh /usr/local/bin/wordpress-post-create.sh /usr/local/bin/wordpress-update-content.sh"
for i in ${EXECUTABLES}; do
    check "Executable ${i} exists" test -x "${i}"
done

FILES="/etc/wp-cli/wp-cli.yaml /usr/share/wordpress/wp-config.php.tpl /usr/share/wordpress/010-wplogin.tpl"
for i in ${FILES}; do
    check "File ${i} exists" test -f "${i}"
done

check "The site works" sh -c "curl -s -w '%{response_code}' -o /dev/null http://localhost/wp-login.php | grep -F 200"
check "We see the expected content" sh -c "curl -s http://localhost/wp-login.php | grep -F '<title>' | grep -F 'WordPress VIP Development Site'"

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
