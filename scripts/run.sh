#!/usr/bin/env bash

DIR="$(dirname "$0")"

# detect docker environment we're running in

# mesos
if [ "x$MESOS_SANDBOX" != "x" ]; then
    echo "MESOS detected"
    . "$DIR/mesos.in.sh"
# weave
elif [ -d "/sys/class/net/ethwe" ]; then
    echo "WEAVE detected"
    . "$DIR/weave.in.sh"
fi

# other peers for discovery
if [ -z "$CRATE_HOSTS" ]; then
    echo "CRATE_HOSTS not specified, using multicast discovery (DEFAULT)"
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.multicast.enabled=false -Des.discovery.zen.ping.unicast.hosts=$CRATE_HOSTS"
    echo "CRATE_HOSTS: using unicast discovery with '$CRATE_HOSTS'"
fi

# HEAP memory
if [ -z "$CRATE_HEAP_SIZE" ]; then
    echo "CRATE_HEAP_SIZE not set, using defaults"
else
    echo "HEAP: $CRATE_HEAP_SIZE"
fi

if [ "x$CRATE_JAVA_OPTS" != "x" ]; then
    echo "CRATE_JAVA_OPTS: '$CRATE_JAVA_OPTS'"
    export CRATE_JAVA_OPTS
fi

/crate/bin/crate
