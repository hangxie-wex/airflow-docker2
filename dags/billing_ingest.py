from typing import Set

from airflow.decorators import dag
from datetime import timedelta, datetime

from tasks.trend import trend
from tasks.invoice import invoice
from tasks.ingest import ingest
from tasks.notify_file_missed import notify_file_missed
from tasks.decrypt_files import decrypt_files
from tasks.transfer_files import transfer_files
from tasks.get_new_files_set import  get_new_files_set

@dag (
    schedule='0 7 * * *',  # every day at 7:00 AM
    start_date=datetime.now() - timedelta(days=1),
    catchup=False,
    default_args={'retries': 1, 'retry_delay': timedelta(minutes=5)},
    tags=['sftp', 'file_processing']
)
def daily_file_dag():
    new_files = get_new_files_set()
    transfer_task = transfer_files(new_files)
    decrypt_task = decrypt_files()
    notify_file_missed_task = notify_file_missed()
    ingest_task = ingest()
    invoice_task = invoice()
    trend_task = trend()

    transfer_task >> decrypt_task >> notify_file_missed_task >> ingest_task >> invoice_task >> trend_task

#     currentFile =transfer_file.expand(file=new_files)
#     descrypt_file = decrypt_file.expand(file=currentFile)
#     billing_file = billing_file_ingestion.expand(file=descrypt_file)
#     invoice_file = invoice_creation.expand(file=billing_file)
#     trend_output = billing_file_trend.expand(file=invoice_file)
#     billing_to_recon_load.expand(file=trend_output)
dag_instance = daily_file_dag()
