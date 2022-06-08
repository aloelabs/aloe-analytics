#!/bin/bash

docker compose build

docker tag pipeline ${GCR_PATH}/pipeline
docker tag api ${GCR_PATH}/api

docker push ${GCR_PATH}/pipeline
docker push ${GCR_PATH}/api