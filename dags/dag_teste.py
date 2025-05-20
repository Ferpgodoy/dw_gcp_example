from airflow.decorators import dag, task
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from datetime import datetime

from ingestion.api_src.api_reader import fetch_api_data
from ingestion.api_src.gcs_uploader import save_json_to_gcs
from transformation.python_scripts.read_sql_scripts import read_parametized_sql
import json
import os
from dotenv import load_dotenv
from datetime import datetime, timedelta

start_date = datetime.now() - timedelta(days=2)


# load environment variables from .env
load_dotenv()
GCP_BUCKET_NAME = os.getenv("GCP_BUCKET_NAME")

@dag(
    schedule='@daily',
    start_date=start_date,
    catchup=True,
    tags=['vendas'],
    default_args={
        'retries': 0,
    }
)
def dag_api_vendas_diaria():

    @task
    def extrair_e_salvar_json(data_agendamento: str, url: str, bucket_name: str, folder: str):
        subfolder = f"{folder}/{data_agendamento}"
        current_timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        file_name = f"{current_timestamp}.json"
        ##vendas_json = fetch_api_data(url) no momento não estou usando, testando de outro jeito
        with open('seuarquivo.json', 'r', encoding='utf-8') as f:
            vendas_json = json.load(f)
        gcs_path = save_json_to_gcs(bucket_name, subfolder, file_name,vendas_json)

        return {
            "data_agendamento": data_agendamento,
            "bucket": bucket_name,
            "file_path": gcs_path
        }

    def task_atualizar_tabela(task_id, sql_path, params):
        sql_final = read_parametized_sql(sql_path, params)
        return BigQueryInsertJobOperator(
            task_id=task_id,
            configuration={
                "query": {
                    "query": sql_final,
                    "useLegacySql": False,
                }
            },
            location="US",
        )

    # Tasks
    dados = extrair_e_salvar_json(data_agendamento="{{ ds }}",url="teste",bucket_name = GCP_BUCKET_NAME,folder="sales")

    bronze = task_atualizar_tabela(
        "atualizar_bronze",
        "../transformation/bronze/sales.sql",
        {
            "data_agendamento": "{{ ds }}",
            "bucket": "{{ ti.xcom_pull(task_ids='extrair_e_salvar_json')['bucket'] }}",
            "file_path": "{{ ti.xcom_pull(task_ids='extrair_e_salvar_json')['file_path'] }}",
        },
    )

    silver = task_atualizar_tabela(
        "atualizar_silver",
        "../transformation/silver/sales.sql",
        {"data_agendamento": "{{ ds }}"},
    )

    gold = task_atualizar_tabela(
        "atualizar_gold",
        "../transformation/gold/sales.sql",
        {"data_agendamento": "{{ ds }}"},
    )

    dados >> bronze >> silver >> gold

dag_api_vendas_diaria = dag_api_vendas_diaria()