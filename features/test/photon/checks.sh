#!/bin/bash

for i in /etc/photon /usr/share/webapps/photon; do
    check "${i} exists" test -d "${i}"
done

for i in /etc/photon/config.php /etc/conf.d/nginx /etc/nginx/conf.extra/photon.conf; do
    check "${i} exists" test -f "${i}"
done

# shellcheck disable=SC2043
for i in /etc/nginx/conf.extra/media-redirect.conf; do
    check "${i} does not exist" test \! -e "${i}"
done

# shellcheck disable=SC2043
for i in /usr/share/webapps/photon/config.php; do
    check "${i} is a symlink" test -L "${i}"
done

for i in pngcrush pngquant jpegoptim jpegtran optipng cwebp cjpeg; do
    check "${i} is executable" which "${i}"
done

ME="$(whoami)"
sudo install -D -d -m 0755 -o "${ME}" -g "${ME}" /wp/wp-content/uploads

install -m 0644 600x400.png /wp/wp-content/uploads/600x400.png

file_size=$(stat -c %s 600x400.png)
content_type="$(curl -s -w '%{content_type}' http://localhost/wp-content/uploads/600x400.png -o /dev/null)"
content_length="$(curl -s -w '%{size_download}' http://localhost/wp-content/uploads/600x400.png -o /dev/null)"

echo "${content_type} ${content_length}"
check "600x400.png; returned as a PNG" test "${content_type}" = 'image/png'
check "600x400.png; content length matches file size" test "${content_length}" = "${file_size}"

content_type="$(curl -s -w '%{content_type}' http://localhost/wp-content/uploads/600x400.png? -o /dev/null)"
content_length="$(curl -s -w '%{size_download}' http://localhost/wp-content/uploads/600x400.png? -o /dev/null)"

echo "${content_type} ${content_length}"
check "600x400.png (optimized); returned as a PNG" test "${content_type}" = 'image/png'
check "600x400.png (optimized); content length is less than file size" test "${content_length}" -lt "${file_size}"

content_type="$(curl -s -w '%{content_type}' -H 'Accept: image/webp' http://localhost/wp-content/uploads/600x400.png? -o /dev/null)"
content_length="$(curl -s -w '%{size_download}' -H 'Accept: image/webp' http://localhost/wp-content/uploads/600x400.png? -o /dev/null)"

echo "${content_type} ${content_length}"
check "600x400.png (as webp); returned as a WEBP" test "${content_type}" = 'image/webp'
check "600x400.png (as webp); content length is less than file size" test "${content_length}" -lt "${file_size}"

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
