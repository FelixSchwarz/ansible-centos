#!/bin/sh
# copied from /usr/bin/mysql_secure_installation with minor modifications to
# remove all user interaction.
# Copyright (c) 2002, 2012, Oracle and/or its affiliates. All rights reserved.
# licensed under the GPLv2

mysql_client="/usr/bin/mysql"
config="/root/.my.cnf"

do_query() {
    command="$1"
    echo "$command" | $mysql_client --defaults-file=$config
    return $?
}


remove_anonymous_users() {
    do_query "DELETE FROM mysql.user WHERE User='';"
    if [ $? -eq 0 ]; then
        echo " ... Success!"
    else
        echo " ... Failed!"
        exit 1
    fi

    return 0
}

remove_remote_root() {
    do_query "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');"
    if [ $? -eq 0 ]; then
        echo " ... Success!"
    else
        echo " ... Failed!"
        exit 1
    fi
}

remove_test_database() {
    echo " - Dropping test database..."
    do_query "DROP DATABASE IF EXISTS test;"
    if [ $? -eq 0 ]; then
        echo " ... Success!"
    else
        echo " ... Failed!"
        exit 1
    fi

    echo " - Removing privileges on test database..."
    do_query "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'"
    if [ $? -eq 0 ]; then
        echo " ... Success!"
    else
        echo " ... Failed!"
        exit 1
    fi

    return 0
}


reload_privilege_tables() {
    do_query "FLUSH PRIVILEGES;"
    if [ $? -eq 0 ]; then
        echo " ... Success!"
        return 0
    else
        echo " ... Failed!"
        return 1
    fi
}


remove_anonymous_users
remove_remote_root
remove_test_database
reload_privilege_tables

