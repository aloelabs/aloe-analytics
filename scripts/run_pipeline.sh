#!/bin/bash

scriptPath=$(dirname "$(readlink -f "$0")")
source "${scriptPath}/.env.sh"

cd /project && \
    meltano elt tap-ccxt target-postgres --job_id=ccxt-to-postgres