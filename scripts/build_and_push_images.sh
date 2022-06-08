#!/bin/bash

docker compose build

docker tag pipeline ${GCR_PATH}/pipeline:${TAG}
docker tag api ${GCR_PATH}/api:${TAG}

docker push ${GCR_PATH}/pipeline
docker push ${GCR_PATH}/api