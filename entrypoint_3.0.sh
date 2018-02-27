#!/bin/sh

set -ae

# GC logging set to default value of path.logs
CRATE_GC_LOG_DIR="/data/log"
# Special VM options for Java in Docker
CRATE_JAVA_OPTS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Des.cgroups.hierarchy.override=/ $CRATE_JAVA_OPTS"

if [ "${1:0:1}" = '-' ]; then
    set -- crate "$@"
fi

if [ "$1" = 'crate' -a "$(id -u)" = '0' ]; then
    chown -R crate:crate /data
    set -- gosu crate "$@"
fi

exec "$@"
