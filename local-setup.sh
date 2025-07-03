#!/bin/bash
echo "--- starting local setup ---"
set -euo pipefail
docker compose down -v
docker-compose build --no-cache
docker compose up -d
docker-compose restart sql_server_test sftp-server localstack airflow-apiserver

echo "--- local setup complete ---"