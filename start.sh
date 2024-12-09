#!/bin/bash
set -e

# if there is no .env file, create one
if [ ! -f .env ]; then
    cp config_example.conf .env
    DB_PASSWORD=$(openssl rand -hex 12)
    REDIS_PASSWORD=$(openssl rand -hex 12)
    SECRET_KEY=$(openssl rand -hex 24)
    BOOTSTRAP_TOKEN=$(openssl rand -hex 24)
    sed -i "s@DB_PASSWORD=.*@DB_PASSWORD=${DB_PASSWORD}@" .env
    sed -i "s@REDIS_PASSWORD=.*@REDIS_PASSWORD=${REDIS_PASSWORD}@" .env
    sed -i "s@SECRET_KEY=.*@SECRET_KEY=${SECRET_KEY}@" .env
    sed -i "s@BOOTSTRAP_TOKEN=.*@BOOTSTRAP_TOKEN=${BOOTSTRAP_TOKEN}@" .env
fi

# Check if docker compose exists, if it does use it
# otherwise use docker-compose
if command -v docker compose > /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
elif command -v docker-compose > /dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
else
    echo "Neither docker compose nor docker-compose is installed, exiting..."
    exit 1
fi

# Running docker compose up
docker compose -f docker-compose-network.yml -f docker-compose-redis.yml -f docker-compose-postgres.yml -f docker-compose.yml up -d
