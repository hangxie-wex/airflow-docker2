from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from helpers.sftp_utils import sftp_download_file
import logging

def download_task():
    log: logging.log = logging.getLogger("airflow")
    log.setLevel(logging.INFO)
    logging.info("testing")
    local_file = "/opt/airflow/dags/example_file.txt"
    remote_file = "/upload/example_file.txt"
    sftp_download_file(local_file, remote_file)

with DAG(
    dag_id="sftp_file_download",
    start_date=datetime(2023, 1, 1),
    tags=["sftp"],
) as dag:
    download = PythonOperator(
        task_id="download_file_to_sftp",
        python_callable=download_task
    )
    download
