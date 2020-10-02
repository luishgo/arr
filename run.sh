#!/bin/sh
HOST_IP=$(ipconfig getifaddr en0) docker stack deploy -c docker-stack.yml arr
