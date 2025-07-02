#!/bin/bash
set -euo pipefail

echo "--- Initializing LocalStack resources ---"

# 1. Create S3 Bucket
echo "Creating S3 bucket: expedia-recon"
awslocal s3 mb s3://expedia-recon

# 2. Create Secrets Manager Secrets for  Connections
SECRET_NAME_S3="local/RiskPlatform/expedia_s3_conn" # Matches Airflow's connection_prefix and conn_id
SECRET_STRING_S3='{"conn_type": "aws", "extra": {"endpoint_url": "http://localstack:4566", "verify": false}, "aws_access_key_id": "test", "aws_secret_access_key": "test"}' # LocalStack doesn't validate

SECRET_NAME_EXPEDIA_SFTP="local/RiskPlatform/expedia-sftp-conn" 
SECRET_STRING_EXPEDIA_SFTP='{"username": "sftpuser",  "password": "password", "hostname": "sftp-server", "port": 22}'

SECRET_NAME_WEX_SFTP="local/RiskPlatform/wex-sftp-conn" 
SECRET_STRING_WEX_SFTP='{"username": "sftpuser",  "password": "password", "hostname": "sftp-server", "port": 22}'

SECRET_NAME_SQL="local/RiskPlatform/srsvc_db_conn" 
SECRET_STRING_SQL='{"conn_id": "srsvc_db_conn", "conn_type": "mssql", "host": "sql_server_test", "port": "1433", "login": "sa", "password": "WexAdmin1!", "schema": "master"}'


REGION="us-east-1" # Must match region in backend_kwargs


echo "Creating Secrets Manager secret for S3: ${SECRET_NAME_S3}"
awslocal secretsmanager create-secret \
  --name "${SECRET_NAME_S3}" \
  --description "LocalStack S3 connection for Airflow" \
  --secret-string "${SECRET_STRING_S3}" \
  --region "${REGION}"

echo "Creating Secrets Manager secret for sftp: ${SECRET_NAME_EXPEDIA_SFTP}"
awslocal secretsmanager create-secret \
  --name "${SECRET_NAME_EXPEDIA_SFTP}" \
  --description "LocalStack expedia sftp connection" \
  --secret-string "${SECRET_STRING_EXPEDIA_SFTP}" \
  --region "${REGION}"

echo "Creating Secrets Manager secret for sftp: ${SECRET_NAME_WEX_SFTP}"
awslocal secretsmanager create-secret \
  --name "${SECRET_NAME_WEX_SFTP}" \
  --description "LocalStack wex sftp connection" \
  --secret-string "${SECRET_STRING_WEX_SFTP}" \
  --region "${REGION}"

echo "Creating Secrets Manager secret for SQL: ${SECRET_NAME_SQL}"
awslocal secretsmanager create-secret \
  --name "${SECRET_NAME_SQL}" \
  --description "LocalStack sql connection for Airflow" \
  --secret-string "${SECRET_STRING_SQL}" \
  --region "${REGION}"


echo "--- LocalStack initialization complete ---"