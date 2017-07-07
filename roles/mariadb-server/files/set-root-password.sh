#!/bin/sh
# copied from /usr/bin/mysql_secure_installation with minor modifications to
# remove all user interaction.
# Copyright (c) 2002, 2012, Oracle and/or its affiliates. All rights reserved.
# licensed under the GPLv2

mysql_client="/usr/bin/mysql"
config="/root/.my.cnf"

do_query() {
    command="$1"
    echo "$command" | $mysql_client
    return $?
}


# Simple escape mechanism (\-escape any ' and \), suitable for two contexts:
# - single-quoted SQL strings
# - single-quoted option values on the right hand side of = in my.cnf
#
# These two contexts don't handle escapes identically.  SQL strings allow
# quoting any character (\C => C, for any C), but my.cnf parsing allows
# quoting only \, ' or ".  For example, password='a\b' quotes a 3-character
# string in my.cnf, but a 2-character string in SQL.
#
# This simple escape works correctly in both places.
basic_single_escape () {
    # The quoting on this sed command is a bit complex.  Single-quoted strings
    # don't allow *any* escape mechanism, so they cannot contain a single
    # quote.  The string sed gets (as argv[1]) is:  s/\(['\]\)/\\\1/g
    #
    # Inside a character class, \ and ' are not special, so the ['\] character
    # class is balanced and contains two characters.
    echo "$1" | sed 's/\(['"'"'\]\)/\\\1/g'
}

set_root_password() {
    esc_pass=`basic_single_escape "$ROOT_PASSWORD"`
    do_query "UPDATE mysql.user SET Password=PASSWORD('$esc_pass') WHERE User='root';"
    return 0
}

set_root_password

