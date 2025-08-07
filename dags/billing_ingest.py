from airflow.decorators import dag, task
from datetime import timedelta, datetime

@task
def get_expected_patterns() -> list[str]:
    return ["expedia", "aging"]

@task
def get_processed_files(patterns: list[str]) -> list[str]:
    return ["expedia_file1.csv"]

@task
def list_sftp_files(patterns: list[str]) -> list[str]:
    all_files = ["expedia_file1.csv", "expedia_file2.csv", "aging_file1.csv"]
    return [f for f in all_files if any(p in f for p in patterns)]

@task
def compare_files(sftp_files: list[str], processed_files: list[str]) -> list[str]:
    return [f for f in sftp_files if f not in processed_files]

@task
def transfer_file(file: str) -> str:
    return file
@task
def decrypt_file(file: str) -> str:
    return file

@task
def billing_file_ingestion(file: str) -> str:
    return file

@task
def invoice_creation(file: str) -> str:
    return file

@task
def billing_file_trend(file: str) -> str:
    return file

@task
def billing_to_recon_load(file: str) -> str:
    return file

@dag (
    schedule='0 7 * * *',  # every day at 7:00 AM
    start_date=datetime.now() - timedelta(days=1),
    catchup=False,
    default_args={'retries': 1, 'retry_delay': timedelta(minutes=5)},
    tags=['sftp', 'file_processing']
)
def daily_file_dag():
    patterns = get_expected_patterns()
    processed = get_processed_files(patterns)
    sftp_files = list_sftp_files(patterns)
    new_files = compare_files(sftp_files, processed)
    currentFile =transfer_file.expand(file=new_files)
    descrypt_file = decrypt_file.expand(file=currentFile)
    billing_file = billing_file_ingestion.expand(file=descrypt_file)
    invoice_file = invoice_creation.expand(file=billing_file)
    trend_output = billing_file_trend.expand(file=invoice_file)
    billing_to_recon_load.expand(file=trend_output)
dag_instance = daily_file_dag()
