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
    tags=['portfolio', 'expedia-recon']
)
def billing_ingest_invoice():
    new_files = get_new_files_set()
    transfer_task = transfer_files(new_files)
    decrypt_task = decrypt_files()
    notify_file_missed_task = notify_file_missed()
    ingest_task = ingest()
    invoice_task = invoice()
    trend_task = trend()

    transfer_task >> decrypt_task >> notify_file_missed_task >> ingest_task >> invoice_task >> trend_task

dag_instance = billing_ingest_invoice()
