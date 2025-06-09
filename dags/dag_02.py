from airflow.decorators import dag
from airflow.utils.task_group import TaskGroup
import pendulum

from tasks.extract_and_save import extract_and_save_json
from tasks.execute_sql import execute_sql

import os
from dotenv import load_dotenv

# Load .env for local development
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
    Generates fake product reviews data, saves it on GCS and executes transformation in three layers on BigQuery (Medallion Architecture):
    - **Bronze**
    - **Silver**
    - **Gold**
    """
)
def dag_product_reviews_update():

    # Extraction
    dados = extract_and_save_json("product_reviews")

    dados


dag_instance = dag_product_reviews_update()