#!/bin/bash

docker build --tag aloe-pipeline --ssh default .

docker tag aloe-pipeline gcr.io/analytics-mvp-345921/aloe-pipeline:latest

docker push gcr.io/analytics-mvp-345921/aloe-pipeline:latest

gcloud compute instances create-with-container aloe-pipeline-vm \
    --container-image gcr.io/analytics-mvp-345921/aloe-pipeline:latest \
    --machine-type=e2-small \
    --container-env-file ./.env.prod \
    --container-arg=invoke \
    --container-arg=airflow \
    --container-arg=scheduler

sleep 10

# gcloud compute instances update-container aloe-pipeline-vm \
#     --container-image gcr.io/analytics-mvp-345921/aloe-pipeline:latest \
#     --container-env-file ./.env.prod \
#     --container-arg=invoke \
#     --container-arg=airflow \
#     --container-arg=scheduler