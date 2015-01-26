#!/usr/bin/env bash

# other peers for discovery
if [ -z "$HOSTS" ]; then
    echo "HOSTS not specified, using multicast discovery (DEFAULT)"
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.multicast.enabled=false -Des.discovery.zen.ping.unicast.hosts=$HOSTS"
    echo "HOSTS: using unicast discovery with '$HOSTS'"
fi
# hostname of the container host
if [ -z "$HOST" ]; then
    echo "HOST: not specified, using '$HOSTNAME' (DEFAULT)"
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.network.publish_host=$HOST"
    echo "HOST: '$HOST' (publish_host)"
fi
# ports for http and transport
if [ -z "$PORT_4200" ]; then
    echo "PORT_4200 not specified, using 4200 (DEFAULT)"
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.http.publish_port=$PORT_4200"
    echo "PORT: $PORT_4200<->4200 (http)"
fi
# outside exposed port for the transport protocol
if [ -z "$PORT_4300" ]; then
    echo "PORT_4300 not specified, using 4300 (DEFAULT)"
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.transport.publish_port=$PORT_4300"
    echo "PORT: $PORT_4300<->4300 (transport)"
fi

# HEAP memory
if [ -z "$CRATE_HEAP_MEM" ]; then
    echo "CRATE_HEAP_MEM not set, using defaults"
else
    echo "HEAP: $CRATE_HEAP_MEM"
fi

/crate/bin/crate
