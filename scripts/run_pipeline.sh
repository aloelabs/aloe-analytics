#!/bin/bash

scriptPath=$(dirname "$(readlink -f "$0")")
source "${scriptPath}/.env.sh"

meltano elt tap-ccxt target-postgres --job_id=ccxt-to-postgres &
meltano elt tap-ethereum target-postgres --job_id=ethereum-to-postgres &
meltano elt tap-thegraph target-postgres --job_id=thegraph-to-postgres &

wait