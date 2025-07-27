from airflow.decorators import task
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from datetime import timedelta
import logging

from include.python_scripts.read_sql_scripts import read_parametized_sql


@task(
    execution_timeout=timedelta(minutes=10),
)
def execute_sql(sql_path: str, parameters: dict):
    logging.info(f"Reading SQL {sql_path} with parameters: {parameters}")
    sql_final = read_parametized_sql(sql_path, parameters)

    bq_client = BigQueryHook(gcp_conn_id="GCP_CONN").get_client()

    result = bq_client.query(sql_final).result()

    logging.info(f"Query executed. {result.total_rows} rows affected.")
    return f"Query successfully executed. {result.total_rows} rows affected."