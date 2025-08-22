import logging
from typing import Set

from airflow.decorators import task


def find_files_to_invoice()-> Set[str]:
    files: Set[str] = {'WEXDaily-20250716-1005367298-USD.txt.gpg', 'AirWEXDaily-20250716-1005367298-USD.txt.gpg'}
    return files

def create_invoice(file:str):
    logging.info(f"creating the invoice for the {file} file")

def create_pdf_file():
    logging.info(f"moving files")

def save_in_network_drive():
    logging.info(f"moving  files")

def process_invoice(file:str):
    create_invoice(file)
    create_pdf_file()
    save_in_network_drive()
    logging.info(f"processing {file} files")

@task
def invoice() -> None:
    files: Set[str] = find_files_to_invoice()
    for file in files:
        process_invoice(file)