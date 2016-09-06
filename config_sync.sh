#! /bin/bash

if [ -f "./config_sync_var.sh" ]; then
    source "./config_sync_var.sh"
fi

CONFIG_FILE_PATH=${CONFIG_FILE_PATH:-"./server.properties"}
FINAL_CONFIG_FILE=${1:-"${CONFIG_FILE_PATH}"}

# sync server configurations to consul kv
if [ -f "$FINAL_CONFIG_FILE" ]; then
    CONSUL_HOST=${CONSUL_HOST:-"127.0.0.1"}
    CONSUL_PORT=${CONSUL_PORT:-8500}
    CONSUL_KV_URL=http://"$CONSUL_HOST":"$CONSUL_PORT"/v1/kv
    CONFIG_KEY_PREFIX=${CONFIG_KEY_PREFIX:-"${RPC_SERVER_NAME}."}

    awk -F '=' '{print $1 " " $2}' "$FINAL_CONFIG_FILE" | while read conf_key conf_value ; do
    syncSucc=$(curl --silent -X PUT "${CONSUL_KV_URL}/${CONFIG_KEY_PREFIX}${conf_key}" -d "${conf_value}")
    if [ "$syncSucc" != "true" ]; then
        echo "sync conf fail: {$conf_key : $conf_value }"
        exit 126
    fi
    done
else
    echo "config file not found: $FINAL_CONFIG_FILE"
    exit 127
fi
