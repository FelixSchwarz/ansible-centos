#!/bin/sh

# --quiet: print only errors
/usr/bin/certbot renew --quiet $*

# cron "notification" about updated certificates
find /etc/letsencrypt/live -name 'cert.pem' -type f -follow -mtime -1

