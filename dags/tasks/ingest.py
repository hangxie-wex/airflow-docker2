import logging
from typing import Set

from airflow.decorators import task


def find_files_to_ingest()-> Set[str]:
    files: Set[str] = {'WEXDaily-20250716-1005367298-USD.txt.gpg', 'AirWEXDaily-20250716-1005367298-USD.txt.gpg'}
    return files

def ingest_files(file:str):
    logging.info(f"ingesting {file} files")

def move_files(file:str):
    logging.info(f"moving {file} files")

def update_files_status(file:str):
    logging.info(f"moving {file} files")


def process_ingest(file:str):
    ingest_files(file)
    move_files(file)
    update_files_status(file)
    logging.info(f"processing {file} files")

@task
def ingest() -> None:
    files: Set[str] = find_files_to_ingest()
    for file in files:
        process_ingest(file)