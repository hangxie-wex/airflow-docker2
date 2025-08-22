import logging
from typing import Set
import pandas as pd

from airflow.decorators import task

def find_files_to_trend()-> Set[str]:
    files: Set[str] = {'WEXDaily-20250716-1005367298-USD.txt.gpg', 'AirWEXDaily-20250716-1005367298-USD.txt.gpg'}
    return files

def calc_current(file:str)-> pd.DataFrame:
    pd_data: pd.DataFrame = pd.read_csv(file)
    logging.info(f"creating {file} files")
    return pd_data

def calc_previous(file:str)-> pd.DataFrame:
    pd_data: pd.DataFrame = pd.read_csv(file)
    return pd_data

def build_email_body(current:pd.DataFrame, previous: pd.DataFrame)-> str:
    logging.info(f"building email body")
    body: str = 'body'
    return body

def sending_email(body: str):
    logging.info(f"sending  files")


def process_trend(file:str):
    current: pd.DataFrame = calc_current(file)
    previous:pd.DataFrame  = calc_previous(file)
    body: str = build_email_body (current, previous)
    sending_email(body)
    logging.info(f"processing {file} files")

@task
def trend() -> None:
    files: Set[str] = find_files_to_trend()
    for file in files:
        process_trend(file)