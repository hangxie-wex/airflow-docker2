import logging

from airflow.decorators import task

@task
def notify_file_missed() -> None:
    logging.info("notifying file missed")