#!/bin/sh
# This file is managed by Ansible. Don't make changes here, they will be overwritten.

DUMPDIR=/srv/borgtmp

DBLIST=`psql --dbname=postgres --quiet --tuples-only --command='SELECT datname from pg_database' | grep -v template`
for dbname in $DBLIST; do
  pg_dump "${dbname}" > ${DUMPDIR}/${dbname}.sql
done

