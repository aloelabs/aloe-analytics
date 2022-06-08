#!/bin/bash

timestamp=$(date +%Y%m%d%H%M%S)

docker compose build

docker tag pipeline ${GCR_PATH}/pipeline:${timestamp}
docker tag api ${GCR_PATH}/api:${timestamp}

docker push ${GCR_PATH}/pipeline:${timestamp}
docker push ${GCR_PATH}/api:${timestamp}