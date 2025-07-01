from airflow import DAG
from airflow.providers.microsoft.mssql.operators.mssql import MsSqlOperator
from datetime import datetime

with DAG(
    dag_id="mssql_sm_example", 
    start_date=datetime(2024, 1, 1),
    tags=["mssql"],
) as dag:

    run_mssql = MsSqlOperator(
        task_id="run_query",
        mssql_conn_id="local_sql_conn",
        sql="SELECT GETDATE();"
    )

    run_mssql