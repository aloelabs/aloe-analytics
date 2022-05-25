#!/bin/bash

scriptPath=$(dirname "$(readlink -f "$0")")
source "${scriptPath}/.env.sh"

cd /project && \
    meltano elt tap-ccxt target-postgres --job_id=ccxt-to-postgres &

cd /project && \
    meltano elt tap-ethereum target-postgres --job_id=ethereum-to-postgres &