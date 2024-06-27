#!/bin/sh

exec /usr/sbin/crond -l 8 -L /var/log/crond.log
