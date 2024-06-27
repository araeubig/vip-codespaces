#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

for i in /etc/photon /usr/share/webapps/photon; do
    check "${i} exists" test -d "${i}"
done

# shellcheck disable=SC2043
for i in /etc/photon/config.php; do
    check "${i} exists" test -f "${i}"
done

for i in /etc/nginx/conf.extra/media-redirect.conf /etc/conf.d/nginx /etc/nginx/conf.extra/photon.conf; do
    check "${i} does not exist" test \! -e "${i}"
done

# shellcheck disable=SC2043
for i in /usr/share/webapps/photon/config.php; do
    check "${i} is a symlink" test -L "${i}"
done

for i in pngcrush pngquant jpegoptim jpegtran optipng cwebp cjpeg; do
    check "${i} does not exist" sh -c "! which \"${i}\""
done

reportResults
