from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
import logging
import boto3
import paramiko
import json

def get_sftp_credentials_sm():
    secret_name = "airflow/connections/local_sftp_conn" # Use the full secret name as registered in Secrets Manager
    region_name = "us-east-1"
    # Change 'airflow/connections' to 'secretsmanager'
    client = boto3.client("secretsmanager", region_name=region_name, endpoint_url="http://localstack:4566")
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response["SecretString"])

def sftp_download_file_sm(local_file_path, remote_file_path):
    creds = get_sftp_credentials_sm()
    logging.info(creds)
    transport = paramiko.Transport((creds["hostname"], creds["port"]))
    transport.connect(username=creds["username"], password=creds["password"])
    sftp = paramiko.SFTPClient.from_transport(transport)
    sftp.get( remote_file_path,local_file_path)
    sftp.close()
    transport.close()

def download_task_sm():
    log: logging.log = logging.getLogger("airflow")
    log.setLevel(logging.INFO)
    logging.info("testing")
    local_file = "/opt/airflow/dags/example_file.txt"
    remote_file = "/upload/example_file.txt"
    sftp_download_file_sm(local_file, remote_file)

with DAG(
    dag_id="sftp_file_download_sm",
    start_date=datetime(2023, 1, 1),
    tags=["sftp"],
) as dag:
    download = PythonOperator(
        task_id="download_file_to_sftp_sm",
        python_callable=download_task_sm
    )
    download
