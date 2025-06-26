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
    Generates fake sales data, saves it on GCS and executes transformation in three layers on BigQuery (Medallion Architecture):
    - **Bronze**
    - **Silver**
    - **Gold**
    """
)
def dag_sales_update():

    # Extract and save JSON to GCS
    dados = extract_and_save_json(data_type="sales")

    # Define grouped transformations using TaskGroup
    with TaskGroup("transformations", tooltip="Layers: Bronze, Silver and Gold") as transformations:

        bronze = execute_sql.override(task_id="bronze")(
            sql_path="transformation/bronze/sales.sql",
            parameters={
                "schedule_date": dados['schedule_date'],
                "bucket": dados['bucket'],
                "file_path": dados['file_path'],
            }
        )

        silver = execute_sql.override(task_id="silver")(
            sql_path="transformation/silver/sales.sql",
            parameters={
                "schedule_date": dados['schedule_date'],
            }
        )

        gold = execute_sql.override(task_id="gold")(
            sql_path="transformation/gold/sales.sql",
            parameters={
                "schedule_date": dados['schedule_date'],
            }
        )

        # Define task dependencies within the transformation group
        bronze >> silver >> gold

    # Define task dependency between extraction and transformation
    dados >> transformations


# Instantiate the DAG
dag_instance = dag_sales_update()
