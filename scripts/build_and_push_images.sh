#!/bin/bash

set -e

timestamp=$(date +%Y%m%d%H%M%S)

docker compose build

docker tag pipeline ${GCR_PATH}/pipeline:${timestamp}
docker tag ${GCR_PATH}/pipeline:${timestamp} ${GCR_PATH}/pipeline:latest
docker tag api ${GCR_PATH}/api:${timestamp}
docker tag ${GCR_PATH}/api:${timestamp} ${GCR_PATH}/api:latest

docker push --all-tags ${GCR_PATH}/pipeline
docker push --all-tags ${GCR_PATH}/api