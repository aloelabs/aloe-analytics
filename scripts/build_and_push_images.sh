#!/bin/bash

set -e

# TODO: fix this somehow so I can use environment variables
GCR_PATH=gcr.io/analytics-mvp-345921

timestamp=$(date +%Y%m%d%H%M%S)

docker compose build

docker tag pipeline ${GCR_PATH}/pipeline:${timestamp}
docker tag pipeline ${GCR_PATH}/pipeline:latest
docker tag api ${GCR_PATH}/api:${timestamp}
docker tag api ${GCR_PATH}/api:latest

docker push --all-tags ${GCR_PATH}/pipeline
docker push --all-tags ${GCR_PATH}/api