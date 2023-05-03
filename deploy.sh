#!/bin/bash

## To update it as per the service requirement pass argument ./deploy.sh app 
# Parse command-line arguments
#if [ $# -eq 0 ]; then
#    echo "Usage: $0 SERVICE_NAME"
#    exit 1
#fi
#SERVICE_NAME=$1

SERVICE_NAME=app

# Check if service exists in docker-compose.yml
#if ! grep -q "^\s*$SERVICE_NAME:" docker-compose.yml; then
#    echo "Error: Service '$SERVICE_NAME' not found in docker-compose.yml"
#    exit 1
#fi

# Get path to Dockerfile for the specified service
DOCKERFILE_PATH=$(grep -A 1 "^\s*$SERVICE_NAME:" docker-compose.yml | grep "dockerfile:" | awk '{print $2}')

# Update Dockerfile if necessary

if [ -f "$DOCKERFILE_PATH.in" ]; then
    echo "Updating Dockerfile for $SERVICE_NAME..."
    envsubst < "$DOCKERFILE_PATH.in" > "$DOCKERFILE_PATH"
fi

# Build new Docker image for the specified service
docker-compose build "$SERVICE_NAME"

# Stop old containers gracefully
OLD_CONTAINERS=$(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" --format "{{.ID}}")
docker-compose stop "$SERVICE_NAME"

# Verify that the old containers have stopped
while [ $(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" -q | wc -l) -gt 0 ]; do
  sleep 1
done

# Start new containers with zero-downtime
docker-compose up --detach --scale "$SERVICE_NAME"=2

# Verify that the new containers are up and running
while [ $(docker ps --filter "name=${SERVICE_NAME}" --filter "status=running" -q | wc -l) -lt 2 ]; do
  sleep 1
done

# Stop and remove old containers that are not running
for CONTAINER in $OLD_CONTAINERS; do
    if [ $(docker inspect --format '{{.State.Status}}' "$CONTAINER") != "running" ]; then
        docker stop "$CONTAINER" >/dev/null
        docker rm "$CONTAINER" >/dev/null
    fi
done

# Tag new image as the latest one
docker tag "appphrase_app:latest" "${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"
#docker tag "${SERVICE_NAME}:latest" "${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"

#To remove the images from local except the recent 3
docker images --format "{{.Repository}}:{{.Tag}}" | grep -iv "latest" | grep app | sort -r | tail -n +4 | xargs docker rmi

# Push new image to a Docker registry (optional)
# docker push "${SERVICE_NAME}:latest"
# docker push "${SERVICE_NAME}:$(date +%Y%m%d%H%M%S)"