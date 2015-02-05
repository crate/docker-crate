#!/bin/sh

# mesos exposes the hostname of the container host as HOST
# outside exposed port for the transport protocol
if [ "x$PUBLISH_HOST" = "x" ]; then
    echo "WEAVE PUBLISH_HOST not set, using the weave interface _ethwe:ipv4_"
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.network.publish_host=_ethwe:ipv4_"
else
    echo "WEAVE PUBLISH_HOST: '$PUBLISH_HOST'"
fi
