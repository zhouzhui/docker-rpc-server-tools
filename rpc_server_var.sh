#! /bin/bash

# can use ansible to generate this file

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
