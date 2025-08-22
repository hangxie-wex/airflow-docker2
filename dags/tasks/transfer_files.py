import logging
from typing import Set

from airflow.decorators import task


@task
def transfer_files(files: Set[str])-> None:
    print(f"Transferring {len(files)} files...")
    print(f" testing ")
    for file in files:
        logging.info(file)

