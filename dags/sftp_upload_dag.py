from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime
from helpers.sftp_utils import sftp_upload_file
import logging

def upload_task():
    log: logging.log = logging.getLogger("airflow")
    log.setLevel(logging.INFO)
    logging.info("testing")
    local_file = "/opt/airflow/dags/example_file.txt"
    remote_file = "example_file.txt"
    sftp_upload_file(local_file, remote_file)

with DAG(
    dag_id="sftp_file_upload",
    start_date=datetime(2023, 1, 1),
    tags=["sftp"],
) as dag:
    upload = PythonOperator(
        task_id="upload_file_to_sftp",
        python_callable=upload_task
    )
    upload
