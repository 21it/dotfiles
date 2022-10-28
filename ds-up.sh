#!/bin/sh

THIS_DIR="$(dirname "$(realpath "$0")")"

echo "==> swarm file verification"
docker-compose \
  -f "$THIS_DIR/docker-compose.workstation.yml" \
  config 1>/dev/null

echo "==> swarm file deploy"
docker stack deploy \
  -c "$THIS_DIR/docker-compose.workstation.yml" workstation
