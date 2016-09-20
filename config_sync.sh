#! /bin/bash

set -e

usage() {
    echo "Usage: sh $0 <configFile>"
    exit 1
}

# ----------------------------------------

if [ $# -lt 1 ]; then
    usage
fi

CONFIG_FILE=$1

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "config file not found: $CONFIG_FILE"
    usage
fi

PROPERTIES_FILE_PATH=${CONFIG_FILE_PATH:-"./server.properties"}

# sync server configurations to consul kv
if [ -f "$PROPERTIES_FILE_PATH" ]; then
    CONSUL_HOST=${CONSUL_HOST:-"127.0.0.1"}
    CONSUL_PORT=${CONSUL_PORT:-8500}
    CONSUL_KV_URL=http://"$CONSUL_HOST":"$CONSUL_PORT"/v1/kv
    CONFIG_KEY_PREFIX=${CONFIG_KEY_PREFIX:-"${RPC_SERVER_NAME}."}

    awk -F '=' '{print $1 " " $2}' "$PROPERTIES_FILE_PATH" | while read conf_key conf_value ; do
    syncSucc=$(curl --silent -X PUT "${CONSUL_KV_URL}/${CONFIG_KEY_PREFIX}${conf_key}" -d "${conf_value}")
    if [ "$syncSucc" != "true" ]; then
        echo "sync conf fail: {$conf_key : $conf_value }"
        exit 126
    fi
    done
else
    echo "properties file not found: $PROPERTIES_FILE_PATH"
    exit 127
fi
