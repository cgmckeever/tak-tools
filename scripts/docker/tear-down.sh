#!/bin/bash

docker compose -f ~/tak-server/docker-compose.yml down
docker volume rm --force tak-server_tak_data
docker system prune -a

sudo rm -rf ~/tak-server