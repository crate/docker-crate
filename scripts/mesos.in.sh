#!/bin/sh

# mesos exposes the hostname of the container host as HOST
MESSAGE="MESOS PUBLISH_HOST: '$HOST'"; print_green
CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.network.publish_host=$HOST"

# mesos exposes the outside visible ports as environment variables
if [ "x$PORT_4200" = "x" ]; then
    MESSAGE="MESOS PORT_4200 not specified, using 4200 (DEFAULT)"; print_yellow
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.http.publish_port=$PORT_4200"
    MESSAGE="MESOS PORT: $PORT_4200<->4200 (http)"; print_green
fi
# outside exposed port for the transport protocol
if [ "x$PORT_4300" = "x" ]; then
    MESSAGE="MESOS PORT_4300 not specified, using 4300 (DEFAULT)"; print_yellow
else
    CRATE_JAVA_OPTS="$CRATE_JAVA_OPTS -Des.transport.publish_port=$PORT_4300"
    MESSAGE="MESOS PORT: $PORT_4300<->4300 (transport)"; print_green
fi

