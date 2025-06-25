import os
import json
import boto3
import paramiko
from botocore.exceptions import ClientError
import logging

def get_sftp_credentials():
    env = os.getenv("AIRFLOW_ENV", "local")
    if env == "prod":
        secret_name = "sftp/credentials"
        region_name = "us-east-1"
        client = boto3.client("secretsmanager", region_name=region_name)
        response = client.get_secret_value(SecretId=secret_name)
        return json.loads(response["SecretString"])
    else:
        with open("/opt/airflow/config/local_secrets.json") as f:
            return json.load(f)

def sftp_upload_file(local_file_path, remote_file_path):
    creds = get_sftp_credentials()
    logging.info(creds)
    transport = paramiko.Transport((creds["hostname"], creds["port"]))
    transport.connect(username=creds["username"], password=creds["password"])
    sftp = paramiko.SFTPClient.from_transport(transport)
    sftp.put(local_file_path, remote_file_path)
    sftp.close()
    transport.close()

def sftp_download_file(local_file_path, remote_file_path):
    creds = get_sftp_credentials()
    logging.info(creds)
    transport = paramiko.Transport((creds["hostname"], creds["port"]))
    transport.connect(username=creds["username"], password=creds["password"])
    sftp = paramiko.SFTPClient.from_transport(transport)
    sftp.get( remote_file_path,local_file_path)
    sftp.close()
    transport.close()