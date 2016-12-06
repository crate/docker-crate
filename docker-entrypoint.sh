#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1:0:1}" = '-' ]; then
    set -- crate "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'crate' -a "$(id -u)" = '0' ]; then
    chown -R crate:crate /config /data
    exec su-exec crate "$0" "$@"
fi

if [ "$1" = 'crate' ]; then

    # if undefined, populate environment variables with sane defaults
    : ${CRATE_BOOTSTRAP_MLOCKALL='true'}
    : ${CRATE_NODE_NAME=''}
    : ${CRATE_PATH_DATA='/data'}
    : ${CRATE_GATEWAY_EXPECTED_NODES=''}
    : ${CRATE_GATEWAY_RECOVER_AFTER_NODES=''}
    : ${CRATE_DISCOVERY_ZEN_MINIMUM_MASTER_NODES=''}
    : ${CRATE_DISCOVERY_ZEN_PING_MULTICAST_ENABLED='false'}
    : ${CRATE_DISCOVERY_ZEN_PING_UNICAST_HOSTS='[]'}
    : ${CRATE_ES_API_ENABLED='false'}

    # if no configfile is provided, generate one based on the environment variables
    if [ ! -f /config/crate.yml ]; then

        # use dist config file and replace settings
        sed -e "s#\#path.data: /path/to/data#path.data: '$CRATE_PATH_DATA'#" \
            -e "s#//userDir: '.*'#userDir: '$CRATE_USER_DIR'#" \
            \
            /config/crate.yml.dist > /config/crate.yml
    fi
    if [ ! -f /config/logging.yml ]; then

        # use dist config file and replace/amend settings
        sed -e "s#//rootLogger: INFO, console, file#rootLogger: INFO, stdout, stderr#" \
            \
            /config/logging.yml.dist > /config/logging.yml

        echo cat << EOF >> /config/logging.yml
  # configure stdout
  stdout:
    type: console
    threshold: DEBUG
    target: System.out
    layout:
      type: consolePattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"

  # configure stderr
  stderr:
    type: console
    threshold: ERROR
    target: System.err
    layout:
      type: consolePattern
      conversionPattern: "[%d{ISO8601}][%-5p][%-25c] %m%n"
EOF

    fi

fi

exec "$@"
