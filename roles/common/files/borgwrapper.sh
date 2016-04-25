#!/bin/bash
# /bin/bash because of ${@:...}

SSHSOURCE=$1
MOUNTPOINT=$2
PRE_SCRIPT=$3
POST_SCRIPT=$4
# BACKUP_SOURCES: parameters $5..
NR_ARGUMENTS=$#

if [ $NR_ARGUMENTS -lt 5 ]; then
    echo USAGE $0 SSHSOURCE MOUNTPOINT PRE_SCRIPT POST_SCRIPT PATH [PATH ...]
    exit 1
fi

if [ "$MOUNTPOINT" == "n/a" ]; then
    BORGREPO="${SSHSOURCE}"
    SSHSOURCE="n/a"
else
    BORGREPO="${MOUNTPOINT}"
fi

if $(grep -qs " ${MOUNTPOINT} fuse.sshfs" /proc/mounts); then
    /bin/true;
elif [ "$SSHSOURCE" != "n/a" ]; then
    /usr/bin/sshfs "${SSHSOURCE}" "${MOUNTPOINT}" -o reconnect,cache=no,noauto_cache,entry_timeout=0
    SSHFS_RESULT=$?
    if [ "$SSHFS_RESULT" != "0" ]; then
        echo "sshfs mounting failed with error ${SSHFS_RESULT}"
        exit 9
    fi
fi

function unmount_sshfs {
    if [ "$MOUNTPOINT" != "n/a" ]; then
        /usr/bin/fusermount -u "${MOUNTPOINT}"
    fi
}

if [ -n "$PRE_SCRIPT" ]; then
    $PRE_SCRIPT
    PRE_RESULT=$?
    if [ "$PRE_RESULT" != "0" ]; then
        echo "PRE_SCRIPT ${PRE_SCRIPT} exited with error ${PRE_RESULT}"
        unmount_sshfs
        exit 10
    fi
fi

export BORG_RELOCATED_REPO_ACCESS_IS_OK=yes

# "${@:5}" means "all arguments of this script starting with the 5th
# (remember, first argument is the script name, four following parameters defined
#  at the top of the script.)
# using "${@:...}" actually escapes arguments containing spaces correctly but
# we must not store that in a simple variable (otherwise the magic is lost)
borg create \
    --compression=lzma,6 ${BORGREPO}::$(date --iso-8601=seconds) \
    "${@:5}"
    #--exclude-caches was only added past 1.0
BORG_RESULT=$?
if [ "$BORG_RESULT" != "0" ]; then
    echo "borg exited with error ${BORG_RESULT}"
    unmount_sshfs
    exit 15
fi

if [ "$(date +%u)" == "0" ]; then
    # on Sunday do a full check (archives might take a while...)
    borg check ${BORGREPO}
    CHECK_RESULT=$?
else
    # on all other days just a quick repo check
    borg check --repository-only ${BORGREPO}
    CHECK_RESULT=$?
fi
if [ "$CHECK_RESULT" != "0" ]; then
    echo "'borg check' exited with error ${CHECK_RESULT}"
    unmount_sshfs
    exit 15
fi

borg prune --keep-daily=7 --keep-weekly=4 --keep-monthly=4 ${BORGREPO}

if [ -n "$POST_SCRIPT" ]; then
    ${POST_SCRIPT}
    POST_RESULT=$?
    if [ "$POST_RESULT" != "0" ]; then
        echo "POST_SCRIPT ${POST_SCRIPT} exited with error ${POST_RESULT}"
        unmount_sshfs
        exit 20
    fi
fi

unmount_sshfs

