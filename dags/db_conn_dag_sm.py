from airflow import DAG
from airflow.providers.microsoft.mssql.operators.mssql import MsSqlOperator
from airflow.hooks.base import BaseHook
from airflow.operators.python import PythonOperator
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook


from datetime import datetime

def debug_connection():
    try:
        conn = BaseHook.get_connection("srsvc_db_conn")
        print(f"Retrieved connection ID: {conn.conn_id}")
        print(f"Retrieved connection type: {conn.conn_type}") # This should be 'mssql'
        print(f"Retrieved connection host: {conn.host}")
        print(f"Retrieved connection port: {conn.port}")
        print(f"Retrieved connection login: {conn.login}")
        print(f"Retrieved connection password: {conn.password}")
        print(f"Retrieved connection schema: {conn.schema}")
        print(f"Retrieved connection extra: {conn.extra}")
    except Exception as e:
        print(f"Error retrieving connection: {e}")

def test_mssql_connection(conn_id):
    try:
        hook = MsSqlHook(mssql_conn_id=conn_id)
        # Get a connection object to test it
        conn = hook.get_conn()
        cursor = conn.cursor()
        cursor.execute("SELECT GETDATE();") # Simple query to test
        result = cursor.fetchone()
        print(f"Successfully connected to MS SQL! Current date/time: {result[0]}")
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Error connecting to MS SQL: {e}")
        raise # Re-raise the exception so Airflow marks the task as failed


with DAG(
    dag_id="mssql_sm_example", 
    start_date=datetime(2024, 1, 1),
    tags=["mssql"],
) as dag:

    debug_task = PythonOperator(
        task_id="debug_sql_connection",
        python_callable=debug_connection,
    )

    debug_sql_connection_task = PythonOperator(
        task_id='debug_sql_connection2',
        python_callable=test_mssql_connection,
        op_kwargs={'conn_id': 'srsvc_db_conn'}, # The ID you successfully retrieved
    )

    debug_task >> debug_sql_connection_task