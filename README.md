# docker-rpc-server-tools

## 同步 rpc server 配置信息到 consul kv
1. 修改 ./config_sync_var.sh 中的配置
    ```sh
    RPC_SERVER_NAME="rpc_test_server"

    # consul host, default to 127.0.0.1
    CONSUL_HOST="127.0.0.1"
    # consul port, default to 8500
    CONSUL_PORT=8500

    # server configuration file, default to "./server.properties"
    CONFIG_FILE_PATH="./server.properties"
    # config key prefix, default to "${RPC_SERVER_NAME}."
    CONFIG_KEY_PREFIX="${RPC_SERVER_NAME}."
    ```
1. 执行 ./config_sync.sh
    ```sh
    ./config_sync.sh
    ```

## 启动 rpc server
1. 前提: 已启动 docker daemon
1. 修改 ./rpc_server_var.sh 中的配置
    ```sh
    # required
    # host of docker daemon
    SERVER_HOST="192.168.31.23"
    GIT_COMMIT="34e9653"
    RPC_SERVER_NAME="rpc_test_server"
    RPC_SERVICE_NAMES=("xxx.xxx.XXService" "yyy.yyy.YYService")

    # server config key prefix, default to "${RPC_SERVER_NAME}."
    CONFIG_KEY_PREFIX=

    # rpc server port, default to random port
    SERVER_PORT=
    # consul host, default to $SERVER_HOST
    CONSUL_HOST="192.168.31.16"
    # consul port, default to 8500
    CONSUL_PORT=8500

    # add to /etc/hosts of docker container, default to empty
    DOCKER_HOST_MAPMPINGS=("vm9:192.168.31.9" "vm11:192.168.31.11" "vm16:192.168.31.16" "vm51:192.168.31.51" "vm52:192.168.31.52")

    # docker registry, default to empty
    DOCKER_REGISTRY=192.168.31.7:5000
    # docker repository, default to empty
    DOCKER_REPOSITORY=htw
    # docker image name, default to "${RPC_SERVER_NAME}"
    DOCKER_IMAGE_NAME="${RPC_SERVER_NAME}"
    # docker image tag, default to "${GIT_COMMIT}"
    DOCKER_IMAGE_TAG="${GIT_COMMIT}"
    ```
1. 执行 ./rpc_server.sh start
    ```sh
    ./rpc_server.sh start
    ```

## 停止 rpc server
1. 前提: 已启动 docker daemon
1. 执行 ./rpc_server.sh stop
    ```sh
    ./rpc_server.sh stop
    ```
