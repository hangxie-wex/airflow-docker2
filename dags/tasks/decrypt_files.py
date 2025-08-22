import logging

from airflow.decorators import task

@task
def decrypt_files() -> None:
    logging.info("Decrypting files")