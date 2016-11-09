#!/bin/sh

# certbot 0.9 prints the following to stderr:
# > Saving debug log to /var/log/letsencrypt/letsencrypt.log
# > Cert not yet due for renewal
# redirecting stderr to stdout so we can filter the output
# (fewer cron messages)
/usr/bin/certbot renew $* 2>&1 | grep '/fullchain.pem' | grep ' (' | grep -v '(skipped)'

