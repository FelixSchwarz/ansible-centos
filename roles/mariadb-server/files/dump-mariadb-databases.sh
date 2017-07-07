#!/bin/bash
# Shell script to backup MySql database
# To backup Mysql databases file to /backup dir and later pick up by your
# script. You can skip few databases from backup too.
# For more info please see (Installation info):
# http://www.cyberciti.biz/nixcraft/vivek/blogger/2005/01/mysql-backup-script.html
# Last updated: Aug - 2005
# --------------------------------------------------------------------
# This is a free shell script under GNU GPL version 2.0 or above
# Copyright (C) 2004, 2005 nixCraft project
# Feedback/comment/suggestions : http://cyberciti.biz/fb/
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------


# Backup Dest directory, change this if you have someother location
DEST=$1
if [ ! -e "${DEST}" ]; then
    echo "destination directory ${DEST} does not exist."
    exit 5
fi

# just rely on ~/.my.cnf
#MyUSER=""       # USERNAME
#MyPASS=""       # PASSWORD
#MyHOST=""       # Hostname
 
# Linux bin paths, change this if it can not be autodetected via which command
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
CHOWN="$(which chown)"
CHMOD="$(which chmod)"
GZIP="$(which gzip)"

# Main directory where backup will be stored
MBD="$DEST"
 
# Get hostname
HOST="$(hostname)"
 
# Get data in dd-mm-yyyy format
NOW="$(date +"%d-%m-%Y")"
 
# File to store current backup file
FILE=""
# Store list of databases
DBS=""
 
# DO NOT BACKUP these databases
IGGY="test information_schema performance_schema"
 
[ ! -d $MBD ] && mkdir -p $MBD || :
 
# Only root can access it!
$CHOWN root.root -R $DEST
$CHMOD 0700 $DEST
 
# Get all database list first
DBS="$($MYSQL -Bse 'show databases')"
 
for db in $DBS; do
    skipdb=-1
    if [ "$IGGY" != "" ]; then
        for i in $IGGY; do
            [ "$db" == "$i" ] && skipdb=1 || :
        done
    fi
    if [ "$skipdb" == "-1" ] ; then
        FILE="$MBD/$db.$HOST.$NOW.sql"
        # do all in one job in pipe,
        # connect to mysql using mysqldump for select mysql database
        # and pipe it out to gz file in backup dir :)
        $MYSQLDUMP $db > $FILE
    fi
done


