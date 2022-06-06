#!/bin/bash

scriptPath=$(dirname "$(readlink -f "$0")")
source "${scriptPath}/.env.sh"

meltano run tap-ccxt target-postgres &
meltano run tap-ethereum target-postgres &
meltano run tap-thegraph target-postgres &

wait

meltano run dbt-postgres:seed dbt-postgres:run 