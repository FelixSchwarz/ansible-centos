#!/bin/sh

/usr/bin/certbot renew $* | grep '/fullchain.pem' | grep ' (' | grep -v '(skipped)'

