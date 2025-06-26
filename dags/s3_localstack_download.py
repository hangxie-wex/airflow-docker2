from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from datetime import datetime

def download_file_from_s3(bucket_name, key, local_path):
    s3_hook = S3Hook(aws_conn_id='aws_default', client_type='s3', verify=False)
    client = s3_hook.get_conn() # Or whatever your AWS connection ID is
    client.download_file(Key=key, Bucket=bucket_name, Filename=local_path)
    print(f"File {key} downloaded from s3://{bucket_name} to {local_path}")
    with open(local_path, 'r') as f:
        content = f.read()
        print(f"Content of downloaded file: {content}")

with DAG(
    dag_id='s3_localstack_download',
    start_date=datetime(2023, 1, 1),
    tags=['s3', 'localstack', 'test'],
) as dag:
    download_task = PythonOperator(
        task_id='download_from_local_s3',
        python_callable=download_file_from_s3,
        op_kwargs={
            'bucket_name': 'my-test-bucket',
            'key': 'test_file.txt',
            'local_path': '/opt/airflow/dags/downloaded_file.txt' # Path accessible inside your Airflow container
        },
    )