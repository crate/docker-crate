#!/bin/sh

# mesos exposes the hostname of the container host as HOST
echo "MESOS PUBLISH_HOST: '$HOST'"
CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.network.publish_host=$HOST"

# mesos exposes the outside visible ports as environment variables
if [ "x$PORT_4200" = "x" ]; then
    echo "MESOS PORT_4200 not specified, using 4200 (DEFAULT)"
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.http.publish_port=$PORT_4200"
    echo "MESOS PORT: $PORT_4200<->4200 (http)"
fi
# outside exposed port for the transport protocol
if [ "x$PORT_4300" = "x" ]; then
    echo "MESOS PORT_4300 not specified, using 4300 (DEFAULT)"
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.transport.publish_port=$PORT_4300"
    echo "MESOS PORT: $PORT_4300<->4300 (transport)"
fi

