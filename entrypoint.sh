#!/bin/sh
set -e

ALLOW=${ALLOW:-0.0.0.0/0}
PORT=${PORT:-873}
TIMEOUT=${TIMEOUT:-600}
SERVE_PATH=${DATA:-/data}
SERVE_NAME=${SERVE_NAME:-data}
MAX_CONNECTIONS=${MAX_CONNECTIONS:-0}

if [ "$1" = 'rsyncd' ]; then
    mkdir -p $SERVE_PATH
	[ -f /etc/rsyncd.conf ] || cat > /etc/rsyncd.conf <<EOF
port = ${PORT}
timeout = ${TIMEOUT}
reverse lookup = false
pid file = /var/run/rsyncd.pid
log file = /dev/stdout
[${SERVE_NAME}]
	path = ${SERVE_PATH}
    max connections = ${MAX_CONNECTIONS}
	uid = root
	gid = root
	hosts deny = *
	hosts allow = ${ALLOW}
	read only = false
    open noatime = true
EOF
    echo "Serving ${SERVE_PATH} at rsync://0.0.0.0:${PORT}/${SERVE_NAME}"
    exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf
else
    exec "$@"
fi
