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

docker context use proxmox
if [ -z "$1" ]; then
    run-traefik
    run-portainer
else
    docker stack deploy -c "$1"/docker-stack.yml "$1"
    #eval run-"$1"
fi