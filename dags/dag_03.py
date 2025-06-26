from airflow.decorators import dag
from airflow.utils.task_group import TaskGroup
from airflow.models import Variable
import pendulum
import os
from dotenv import load_dotenv

from dags.tasks.extract_and_save import extract_and_save_json
from dags.tasks.execute_sql import execute_sql

@dag(
    schedule='@daily',
    start_date=pendulum.datetime(2024, 5, 20, tz="America/Sao_Paulo"),
    catchup=False,
    tags=["example"],
    params={"row_count": 1000},
    doc_md="""
    ### DAG: Sales Update
    Generates fake site sessions data, saves it on GCS and executes transformation in three layers on BigQuery (Medallion Architecture):
    - **Bronze**
    - **Silver**
    - **Gold**
    """
)
def dag_site_sessions_update():

    # Extraction
    dados = extract_and_save_json(data_type="site_sessions")

    dados


dag_instance = dag_site_sessions_update()