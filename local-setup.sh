#!/bin/bash
echo "--- starting local setup ---"
set -euo pipefail
docker-compose down --volumes --remove-orphans
docker-compose build --no-cache
docker compose up -d
echo "--- sleeping 120 seconds to wait for the services to initialize completely ---"
sleep 120
echo "--- restart the servoces ---"
docker-compose restart sql_server_test sftp-server localstack  airflow-webserver

echo "--- local setup complete ---"