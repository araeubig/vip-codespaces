#!/bin/sh

if [ -f composer.json ] && [ -x /usr/local/bin/composer ]; then
    /usr/local/bin/composer install -n || true
fi
