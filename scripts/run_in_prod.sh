#!/bin/sh

# Kill existing tmux server
tmux kill-server

# Stop the running services
docker compose -f production.yml down

# Remove the old Docker images and containers
docker system prune -a

# Pull the latest images
docker compose -f production.yml pull

# Start the containers
docker compose -f production.yml up -d

# View the logs for the pipeline (left) and api (right)
tmux new-session -d -s aloe_analytics 'docker compose -f production.yml logs -f pipeline'
tmux split-window -h 'docker compose -f production.yml logs -f api'
tmux attach -t aloe_analytics