from airflow.decorators import dag, task
from datetime import datetime, timedelta
from python_scripts.api_reader import fetch_api_data
from python_scripts.gcs_uploader import save_json_to_gcs
from python_scripts.read_sql_scripts import read_parametized_sql
from python_scripts.generate_fake_data import generate_sales
import json
import os
from dotenv import load_dotenv
from google.cloud import bigquery

# Load environment variables from .env
load_dotenv()
GCP_BUCKET_NAME = os.getenv("GCP_BUCKET_NAME")

@dag(
    schedule='@daily',
    start_date=datetime.today() - timedelta(days=2),
    catchup=False,
    tags=["exemplo"],
)
def dag_sales_update():

    @task
    def extract_and_save_json(schedule_date: str, url: str, bucket_name: str, folder: str):
        subfolder = f"{folder}/{schedule_date}"
        current_timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        file_name = f"{current_timestamp}.json"
        # vendas_json = fetch_api_data(url)  # not used in the moment, testing other parts of the code
        sales_json = generate_sales(schedule_date, count=1000)
        gcs_path = save_json_to_gcs(bucket_name, subfolder, file_name, sales_json)

        return {
            "bucket": bucket_name,
            "file_path": gcs_path
        }

    @task
    def update_table(sql_path: str, parameters: dict):
        sql_final = read_parametized_sql(sql_path, parameters)
        client = bigquery.Client()
        query_job = client.query(sql_final)
        result = query_job.result()

        return f"Query executada com sucesso, {result.total_rows} linhas afetadas."

    dados = extract_and_save_json(
        schedule_date="{{ ds }}",
        url="teste",
        bucket_name=GCP_BUCKET_NAME,
        folder="sales"
    )

    bronze = update_table.override(task_id="bronze")(
        sql_path="transformation/bronze/sales.sql",
        parameters={
            "schedule_date": "{{ ds }}",
            "bucket": "{{ ti.xcom_pull(task_ids='extract_and_save_json')['bucket'] }}",
            "file_path": "{{ ti.xcom_pull(task_ids='extract_and_save_json')['file_path'] }}",
        }
    )

    silver = update_table.override(task_id="silver")(
        sql_path="transformation/silver/sales.sql",
        parameters={"schedule_date": "{{ ds }}"},
    )

    gold = update_table.override(task_id="gold")(
        sql_path="transformation/gold/sales.sql",
        parameters={"schedule_date": "{{ ds }}"},
    )

    dados >> bronze >> silver >> gold

dag_instance = dag_sales_update()
