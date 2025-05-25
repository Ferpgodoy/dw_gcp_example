from airflow.decorators import dag, task
from airflow.utils.task_group import TaskGroup
from airflow.operators.python import get_current_context
import pendulum
from datetime import datetime, timedelta
import logging
import os
from dotenv import load_dotenv
from google.cloud import bigquery
from python_scripts.api_reader import fetch_api_data
from python_scripts.gcs_uploader import save_json_to_gcs
from python_scripts.read_sql_scripts import read_parametized_sql
from python_scripts.generate_fake_data import generate_sales

# Load environment variables from .env
load_dotenv()
GCP_BUCKET_NAME = os.getenv("GCP_BUCKET_NAME")

@dag(
    schedule='@daily',
    start_date=pendulum.datetime(2024, 5, 20, tz="America/Sao_Paulo"),
    catchup=False,
    tags=["example"],
    params={"row_count": 1000, "bucket": GCP_BUCKET_NAME},
    doc_md="""
    ### DAG: Sales Update

    This DAG generates fake sales data, saves it on GCS and executes transformation in three layers on BigQuery (Medallion Architecture):
    - **Bronze**
    - **Silver**
    - **Gold**
    """
)
def dag_sales_update():

    @task(
        retries=3,
        retry_delay=timedelta(minutes=5),
        execution_timeout=timedelta(minutes=30),
        doc_md="Generate fake sales data and save as JSON in GCS."
    )
    def extract_and_save_json():
        context = get_current_context()
        schedule_date = context['ds']
        bucket_name = context['params']['bucket']
        row_count = context['params']['row_count']

        folder = "sales"
        subfolder = f"{folder}/{schedule_date}"
        current_timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        file_name = f"{current_timestamp}.json"

        logging.info(f"Generating fake sales data for {schedule_date} with {row_count} rows.")
        sales_json = generate_sales(schedule_date, count=row_count)
        if not sales_json:
            logging.error("No sales data generated.")
            raise ValueError("Empty data.")

        logging.info(f"Saving file {file_name} to gs://{bucket_name}/{subfolder}")
        gcs_path = save_json_to_gcs(bucket_name, subfolder, file_name, sales_json)

        return {"bucket": bucket_name, "file_path": gcs_path, "schedule_date": schedule_date}

    @task(
        execution_timeout=timedelta(minutes=10),
        doc_md="Executes parameterized SQL on BigQuery and returns rows affected."
    )
    def update_table(sql_path: str, parameters: dict):
        logging.info(f"Reading SQL {sql_path} with parameters: {parameters}")
        sql_final = read_parametized_sql(sql_path, parameters)
        
        client = bigquery.Client()
        query_job = client.query(sql_final)
        result = query_job.result()

        logging.info(f"Query successfully executed. {result.total_rows} rows affected.")
        return f"Query successfully executed. {result.total_rows} rows affected."

    # Extração
    dados = extract_and_save_json()

    # Transformações agrupadas
    with TaskGroup("transformations", tooltip="Layers: Bronze, Silver and Gold") as transformations:

        bronze = update_table.override(task_id="bronze")(
            sql_path="transformation/bronze/sales.sql",
            parameters={
                "schedule_date": "{{ ti.xcom_pull(task_ids='extract_and_save_json')['schedule_date'] }}",
                "bucket": "{{ ti.xcom_pull(task_ids='extract_and_save_json')['bucket'] }}",
                "file_path": "{{ ti.xcom_pull(task_ids='extract_and_save_json')['file_path'] }}",
            }
        )

        silver = update_table.override(task_id="silver")(
            sql_path="transformation/silver/sales.sql",
            parameters={
                "schedule_date": "{{ ti.xcom_pull(task_ids='extract_and_save_json')['schedule_date'] }}",
            }
        )

        gold = update_table.override(task_id="gold")(
            sql_path="transformation/gold/sales.sql",
            parameters={
                "schedule_date": "{{ ti.xcom_pull(task_ids='extract_and_save_json')['schedule_date'] }}",
            }
        )

        bronze >> silver >> gold

    dados >> transformations

dag_instance = dag_sales_update()
