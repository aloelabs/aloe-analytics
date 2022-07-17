#!/bin/sh

docker compose -f production.yml down && 
docker system prune -a && 
docker compose -f production.yml pull && 
docker compose -f production.yml up -d