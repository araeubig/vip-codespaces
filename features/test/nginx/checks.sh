#!/bin/bash

if hash sv >/dev/null 2>&1; then
    check "nginx is running" sudo sh -c 'sv status nginx | grep -E ^run:'
    sudo sv stop nginx
    check "nginx is stopped" sudo sh -c 'sv status nginx | grep -E ^down:'
    sudo sv start nginx
    check "nginx is running" sudo sh -c 'sv status nginx | grep -E ^run:'
else
    check "nginx is running" pgrep nginx
fi

check "Port 80 is open" sh -c 'netstat -lnt | grep :80 '

sudo install -d /wp
echo Test | sudo tee /wp/test.txt
echo '<?php echo "Test"; ?>' | sudo tee /wp/test.php

check "nginx serves /test.txt" sh -c "curl -s http://localhost/test.txt | grep Test"
check "nginx serves /test.php" sh -c "curl -s http://localhost/test.php | grep Test"

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
