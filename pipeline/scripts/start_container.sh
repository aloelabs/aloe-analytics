#!/bin/bash

scriptPath=$(dirname "$(readlink -f "$0")")

printenv | sed 's/^\(.*\)$/export \1/g' > ${scriptPath}/.env.sh
chmod +x ${scriptPath}/.env.sh

${scriptPath}/run_pipeline.sh

cron

tail -f /var/log/cron.log