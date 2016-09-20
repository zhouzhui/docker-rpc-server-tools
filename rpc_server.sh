#! /bin/bash

set -e

usage() {
    echo "Usage: sh $0 <configFile> <start|stop>"
    exit 1
}

# ----------------------------------------

if [ $# -lt 2 ]; then
    usage
fi

CONFIG_FILE=$1
COMMAND=$2

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "config file not found: $CONFIG_FILE"
    usage
fi

RPC_SERVER_NAME=${RPC_SERVER_NAME:-""}
if [ ${#RPC_SERVER_NAME} -le 0 ]; then
    echo "RPC_SERVER_NAME not provided"
    exit 1
fi

DOCKER_EXEC="${DOCKER_EXEC:-docker}"

# ----------------------------------------

# start rpc server
do_start() {
    SERVER_HOST="${SERVER_HOST:-""}"
    GIT_COMMIT=${GIT_COMMIT:-""}
    RPC_SERVICE_NAMES=${RPC_SERVICE_NAMES:-()}
    if [ ${#SERVER_HOST} -le 0 ]; then
        echo "SERVER_HOST not provided"
        exit 1
    fi
    if [ ${#GIT_COMMIT} -le 0 ]; then
        echo "GIT_COMMIT not provided"
        exit 1
    fi
    if [ ${#RPC_SERVICE_NAMES[@]} -le 0 ]; then
        echo "RPC_SERVICE_NAMES not provided"
        exit 1
    fi

    CONSUL_HOST="${CONSUL_HOST:-$SERVER_HOST}"
    CONSUL_PORT=${CONSUL_PORT:-8500}
    CONSUL_REGISTER_SERVICE_URL=http://"$CONSUL_HOST":"$CONSUL_PORT"/v1/agent/service/register

    DOCKER_REGISTRY=${DOCKER_REGISTRY:-""}
    DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-""}
    DOCKER_IMAGE_NAME=${DOCKER_IMAGE_NAME:-"$RPC_SERVER_NAME"}
    DOCKER_IMAGE_TAG=${DOCKER_IMAGE_TAG:-"$GIT_COMMIT"}

    DOCKER_IMAGE="${DOCKER_IMAGE_NAME}":"${DOCKER_IMAGE_TAG}"
    if [ ${#DOCKER_REPOSITORY} -gt 0 ]; then
        DOCKER_IMAGE="${DOCKER_REPOSITORY}/$DOCKER_IMAGE"
    fi
    if [ ${#DOCKER_REGISTRY} -gt 0 ]; then
        DOCKER_IMAGE="${DOCKER_REGISTRY}/$DOCKER_IMAGE"
    fi

    RANDOM_PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
    RPC_PORT=${SERVER_PORT:-$RANDOM_PORT}

    DOCKER_OPTS="-d --restart=always --name $RPC_SERVER_NAME -p $RPC_PORT:$RPC_PORT"
    DOCKER_HOST_MAPMPINGS=${DOCKER_HOST_MAPMPINGS:-()}
    for HOST_MAPPING in ${DOCKER_HOST_MAPMPINGS[@]};
    do
        DOCKER_OPTS="$DOCKER_OPTS --add-host $HOST_MAPPING"
    done

    CONFIG_KEY_PREFIX=${CONFIG_KEY_PREFIX:-"${RPC_SERVER_NAME}."}
    DOCKER_IMAGE_ARGS="--rpc-server-port=${RPC_PORT}"
    DOCKER_IMAGE_ARGS="$DOCKER_IMAGE_ARGS --config-key-prefix=${CONFIG_KEY_PREFIX}"
    DOCKER_IMAGE_ARGS="$DOCKER_IMAGE_ARGS --config-server-host=${CONSUL_HOST} --config-server-port=${CONSUL_PORT}"

    # start docker container
    $DOCKER_EXEC run $DOCKER_OPTS $DOCKER_IMAGE $DOCKER_IMAGE_ARGS

    # register service to consul agent
    for RPC_SERVICE_NAME in ${RPC_SERVICE_NAMES[@]};
    do
    RPC_SERVICE_ID="$RPC_SERVICE_NAME"@"$SERVER_HOST":$RPC_PORT
    read -d '' CONSUL_SERVICE_DEF << EOF
{
  "ID": "$RPC_SERVICE_ID",
  "Name": "$RPC_SERVICE_NAME",
  "Tags": [
    "$GIT_COMMIT"
  ],
  "Address": "$SERVER_HOST",
  "Port": $RPC_PORT,
  "EnableTagOverride": false,
  "Check": {
    "DeregisterCriticalServiceAfter": "90m",
    "TCP": "$SERVER_HOST:$RPC_PORT",
    "Interval": "10s"
  }
}
EOF
    echo "$CONSUL_SERVICE_DEF" | curl -H "Content-Type: application/json" -X PUT "$CONSUL_REGISTER_SERVICE_URL" -d @-
    done
}

# ----------------------------------------

do_stop() {
    $DOCKER_EXEC stop $RPC_SERVER_NAME && $DOCKER_EXEC rm $RPC_SERVER_NAME > /dev/null
}

# ----------------------------------------

case "$COMMAND" in
    start)
    do_start
    ;;
    stop)
    do_stop
    ;;
    *)
    echo "Usage: $0 {start|stop}" >&2
    exit 1
    ;;
esac
