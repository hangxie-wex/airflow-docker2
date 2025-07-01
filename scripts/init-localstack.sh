#!/bin/bash
set -euo pipefail

echo "--- Initializing LocalStack resources ---"

# 1. Create S3 Bucket
echo "Creating S3 bucket: local-airflow-bucket"
awslocal s3 mb s3://local-airflow-bucket

# 2. Create Secrets Manager Secrets for  Connections
SECRET_NAME_S3="airflow/connections/local_s3_conn" # Matches Airflow's connection_prefix and conn_id
SECRET_STRING_S3='{"conn_type": "aws", "extra": {"endpoint_url": "http://localstack:4566", "verify": false}, "aws_access_key_id": "test", "aws_secret_access_key": "test"}' # LocalStack doesn't validate

SECRET_NAME_SFTP="airflow/connections/local_sftp_conn" 
SECRET_STRING_SFTP='{"username": "sftpuser",  "password": "password", "hostname": "sftp-server", "port": 22}'

SECRET_NAME_SQL="airflow/connections/local_sql_conn" 
SECRET_STRING_SQL='{"conn_id": "local_sql_conn", "conn_type": "mssql", "host": "sql_server_test", "port": "1433", "login": "sa", "password": "WexAdmin1!", "schema": "master"}'


REGION="us-east-1" # Must match region in backend_kwargs


echo "Creating Secrets Manager secret for S3: ${SECRET_NAME_S3}"
awslocal secretsmanager create-secret \
  --name "${SECRET_NAME_S3}" \
  --description "LocalStack S3 connection for Airflow" \
  --secret-string "${SECRET_STRING_S3}" \
  --region "${REGION}"

echo "Creating Secrets Manager secret for S3: ${SECRET_NAME_SFTP}"
awslocal secretsmanager create-secret \
  --name "${SECRET_NAME_SFTP}" \
  --description "LocalStack sftp connection for Airflow" \
  --secret-string "${SECRET_STRING_SFTP}" \
  --region "${REGION}"

echo "Creating Secrets Manager secret for SQL: ${SECRET_NAME_SQL}"
awslocal secretsmanager create-secret \
  --name "${SECRET_NAME_SQL}" \
  --description "LocalStack sql connection for Airflow" \
  --secret-string "${SECRET_STRING_SQL}" \
  --region "${REGION}"



echo "--- LocalStack initialization complete ---"