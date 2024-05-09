#!/bin/bash
function config-create-if-needed() {
    local filePath=$1
    local hash=$(sha1sum ${filePath} | awk '{print substr($1,0,8)}')
    local file=$(basename ${filePath})
    docker config inspect ${file}.${hash} &>/dev/null || docker config create ${file}.${hash} ${filePath} &>/dev/null
    echo ${file}.${hash}
}

function secret-create-if-needed() {
    local filePath=$1
    local hash=$(sha1sum ${filePath} | awk '{print substr($1,0,8)}')
    local file=$(basename ${filePath})
    docker secret inspect ${file}.${hash} &>/dev/null || docker secret create ${file}.${hash} ${filePath} &>/dev/null
    echo ${file}.${hash}
}

function run-traefik() {
    docker network inspect traefik &>/dev/null || docker network create --driver overlay --attachable=true traefik

    TRAEFIK_FILE=$(config-create-if-needed traefik/traefik.toml) \
    docker stack deploy -c traefik/docker-stack.yml traefik
}

function run-portainer() {
    docker stack deploy -c portainer/docker-stack.yml portainer
}

function run-arr() {
    docker stack deploy -c arr/docker-stack.yml arr
}

function run-heimdall() {
    docker stack deploy -c heimdall/docker-stack.yml heimdall
}

docker context use proxmox
if [ -z "$1" ]; then
    run-traefik
    run-portainer
else
    eval run-"$1"
fi