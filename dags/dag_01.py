from airflow.decorators import dag, task_group
import pendulum

from dags.tasks.extract_and_save import extract_and_save_json
from dags.tasks.execute_sql import execute_sql
from dags.tasks.export_xlsx import extract_bigquery_to_gcs_xlsx

# ------------------------
# modularized Task Group
# ------------------------

@task_group(group_id="transformations", tooltip="Layers: Bronze, Silver and Gold")
def sales_transformations(schedule_date: str, bucket: str, file_path: str):

    bronze = execute_sql.override(task_id="bronze")(
        sql_path="../include/transformation/bronze/sales.sql",
        parameters={
            "schedule_date": schedule_date,
            "bucket": bucket,
            "file_path": file_path,
        }
    )

    silver = execute_sql.override(task_id="silver")(
        sql_path="../include/transformation/silver/sales.sql",
        parameters={
            "schedule_date": schedule_date,
        }
    )

    gold = execute_sql.override(task_id="gold")(
        sql_path="../include/transformation/gold/sales.sql",
        parameters={
            "schedule_date": schedule_date,
        }
    )

    bronze >> silver >> gold

# ------------------------
# Main DAG
# ------------------------

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

    # Execute SQL transformations
    transformation = sales_transformations(
        schedule_date=dados["schedule_date"],
        bucket=dados["bucket"],
        file_path=dados["file_path"]
    )

    export = extract_bigquery_to_gcs_xlsx(
        sql_path="transformation/export/sales.sql",
        data_type="sales",
        parameters={},
        schedule_date=dados["schedule_date"]
    )

    dados >> transformation >> export

# DAG Instance
dag_instance = dag_sales_update()

