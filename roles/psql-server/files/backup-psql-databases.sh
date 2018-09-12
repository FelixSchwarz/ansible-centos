#!/bin/sh
# This file is managed by Ansible. Don't make changes here, they will be overwritten.

# The "root" user may not exist as postgres user. Trying switching to "postgres".
PSQL_USER=postgres
USER=$(id --name --user)
if [ "${USER}" != "${PSQL_USER}" ]; then
   su - "${PSQL_USER}" --shell=/bin/bash --command ${BASH_SOURCE}
   RC=$?
   exit $RC
fi

DUMPDIR=/srv/borgtmp

DBLIST=`psql --dbname=postgres --quiet --tuples-only --command='SELECT datname from pg_database' | grep -v template`
for dbname in $DBLIST; do
  pg_dump "${dbname}" > ${DUMPDIR}/${dbname}.sql
done

