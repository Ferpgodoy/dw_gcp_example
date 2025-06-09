from airflow.decorators import task
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from datetime import timedelta
import logging

from python_scripts.read_sql_scripts import read_parametized_sql


@task(
    execution_timeout=timedelta(minutes=10),
)
def execute_sql(sql_path: str, parameters: dict):
    logging.info(f"Reading SQL {sql_path} with parameters: {parameters}")
    sql_final = read_parametized_sql(sql_path, parameters)
    # Try BigQueryHook first (works no Astronomer)
    try:
        bq_client = BigQueryHook(gcp_conn_id="STAGE_GCP").get_client()
    except Exception:
        logging.warning("Falling back to local BigQuery client using default credentials.")
        from google.cloud import bigquery
        bq_client = bigquery.Client()
 
    query_job = bq_client.query(sql_final)
    result = query_job.result()

    logging.info(f"Query executed. {result.total_rows} rows affected.")
    return f"Query successfully executed. {result.total_rows} rows affected."