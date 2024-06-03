#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "php exists" which php
check "php-fpm exists" which php-fpm
check "pecl exists" which pecl
check "pear exists" which pear
check "composer exists" which composer
check "www-data user exists" getent passwd www-data
check "www-data group exists" getent group www-data

# gnupg is not available on Alpine
MODULES="apcu bcmath calendar ctype curl date dom exif fileinfo filter ftp gd gmagick gmp hash iconv igbinary intl json libxml mbstring mcrypt memcache memcached mysqli mysqlnd openssl pcntl pcre pdo_mysql pdo_sqlite phar posix random reflection session shmop simplexml soap sockets sodium sqlite3 ssh2 sysvsem sysvshm timezonedb tokenizer xml xmlreader xmlwriter zip zlib"
for module in ${MODULES}; do
    check "PHP module ${module} exists" sh -c "php -m | grep -qi ^${module}$"
done

check "composer version" composer --version

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
