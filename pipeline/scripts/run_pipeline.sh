#!/bin/bash

set -e

cd /project

# Load environment variables
scriptPath=$(dirname "$(readlink -f "$0")")
source "${scriptPath}/.env.sh"

# Run pipelines
meltano run tap-ccxt target-postgres
meltano run tap-ethereum target-postgres
meltano run tap-thegraph target-postgres

# Run dbt transforms
meltano run dbt-postgres:seed dbt-postgres:run 