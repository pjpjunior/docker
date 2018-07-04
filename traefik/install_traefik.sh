#!/bin/sh
docker network create web
docker run -d -p 8088:8080 -p 80:80 --name=traefik --network=web -v $PWD/traefik.toml:/etc/traefik/traefik.toml -v /var/run/docker.sock:/var/run/docker.sock  traefik:alpine
