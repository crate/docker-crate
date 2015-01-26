#!/usr/bin/env bash

# some helper functions for coloured output
print_red() {
    echo -e "\e[1;31m$MESSAGE\e[0m"
}
print_yellow() {
    echo -e "\e[1;33m$MESSAGE\e[0m"
}
print_green() {
    echo -e "\e[1;32m$MESSAGE\e[0m"
}
print_blue() {
    echo -e "\e[1;34m$MESSAGE\e[0m"
}

DIR="$(dirname "$0")"

# detect docker environment we're running in

# mesos
if [ "x$MESOS_SANDBOX" != "x" ]; then
    MESSAGE="MESOS detected"; print_blue
    . "$DIR/mesos.in.sh"
# weave
elif [ -d "/sys/class/net/ethwe" ]; then
    MESSAGE="WEAVE detected"; print_blue
    . "$DIR/weave.in.sh"
fi

# other peers for discovery
MESSAGE="CRATE_HOSTS"; print_blue
if [ -z "$CRATE_HOSTS" ]; then
    MESSAGE="not specified, using multicast discovery (DEFAULT)"; print_yellow
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.multicast.enabled=false -Des.discovery.zen.ping.unicast.hosts=$CRATE_HOSTS"
    MESSAGE="using unicast discovery with '$CRATE_HOSTS'"; print_green
fi


# HEAP memory
MESSAGE="CRATE_HEAP_SIZE"; print_blue
if [ -z "$CRATE_HEAP_SIZE" ]; then
    MESSAGE="not set, using defaults"; print_yellow
else
    MESSAGE="$CRATE_HEAP_SIZE"; print_green
fi

# extend CRATE_JAVA_OPTS with command line arguments passed into docker
CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS $@"

MESSAGE="CRATE_JAVA_OPTS"; print_blue
if [ "x$CRATE_JAVA_OPTS" != "x" ]; then
    MESSAGE="$CRATE_JAVA_OPTS"; print_green
    export CRATE_JAVA_OPTS
fi

echo ''
MESSAGE="Starting Crate ..."; print_blue

# send signal to process
func_exit(){
    kill -INT $PID
}

trap func_exit INT TERM
exec /crate/bin/crate

PID=$!
wait $PID
exit

