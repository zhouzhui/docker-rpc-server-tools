#! /bin/bash

# can use ansible to generate this file

# required
RPC_SERVER_NAME="rpc_test_server"

# consul host, default to 127.0.0.1
CONSUL_HOST="127.0.0.1"
# consul port, default to 8500
CONSUL_PORT=8500

# server configuration file, default to "./server.properties"
CONFIG_FILE_PATH="./server.properties"
# config key prefix, default to "${RPC_SERVER_NAME}."
CONFIG_KEY_PREFIX="${RPC_SERVER_NAME}."
