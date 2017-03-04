#!/bin/sh

# --quiet: print only errors
/usr/bin/certbot renew --quiet $*

# prevent error message if no certificate exists
[ -e /etc/letsencrypt/live ] || exit 0

# cron "notification" about updated certificates
#
# -mmin -1380: all files modified less than 23 hours (23 * 60 minutes) ago
# I often saw a duplicated notification on the day after renewal when just
# using the more common "-mtime -1" ("one day").
find /etc/letsencrypt/live -name 'cert.pem' -type f -follow -mmin -1380

