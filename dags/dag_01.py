from airflow.decorators import dag, task
from datetime import datetime, timedelta
from python_scripts.api_reader import fetch_api_data
from python_scripts.gcs_uploader import save_json_to_gcs
from python_scripts.read_sql_scripts import read_parametized_sql
import json
import os
from dotenv import load_dotenv
from google.cloud import bigquery

# load environment variables from .env
load_dotenv()
GCP_BUCKET_NAME = os.getenv("GCP_BUCKET_NAME")

@dag(
    schedule='@daily',  # ou use um cron string se quiser agendamento
    start_date=datetime.today() - timedelta(days=2),
    catchup=False,
    tags=["exemplo"],
)
def dag_hello_goodbye():

    @task
    def extrair_e_salvar_json(data_agendamento: str, url: str, bucket_name: str, folder: str):
        subfolder = f"{folder}/{data_agendamento}"
        current_timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        file_name = f"{current_timestamp}.json"
        # vendas_json = fetch_api_data(url)  # não usado no momento, estático para teste
        with open('vendas.json', 'r', encoding='utf-8') as f:
            vendas_json = json.load(f)
        gcs_path = save_json_to_gcs(bucket_name, subfolder, file_name, vendas_json)

        return {
            "data_agendamento": data_agendamento,
            "bucket": bucket_name,
            "file_path": gcs_path
        }

    @task
    def atualizar_tabela(sql_path: str, parametros: dict):
        # Lê SQL parametrizado
        sql_final = read_parametized_sql(sql_path, parametros)
        print(sql_final)
        
        # Cria cliente BigQuery
        client = bigquery.Client()
        
        # Executa a query
        query_job = client.query(sql_final)
        result = query_job.result()  # espera a execução finalizar
        
        return f"Query executada com sucesso, {result.total_rows} linhas afetadas."

    dados = extrair_e_salvar_json(
        data_agendamento="{{ ds }}",
        url="teste",
        bucket_name=GCP_BUCKET_NAME,
        folder="sales"
    )

    bronze = atualizar_tabela(
        sql_path="transformation/bronze/sales.sql",
        parametros=
        {
            "data_agendamento": "{{ ds }}",
            "bucket": "{{ ti.xcom_pull(task_ids='extrair_e_salvar_json')['bucket'] }}",
            "file_path": "{{ ti.xcom_pull(task_ids='extrair_e_salvar_json')['file_path'] }}",
        }
    )

    silver = atualizar_tabela(
        sql_path="transformation/silver/sales.sql",
        parametros={"data_agendamento": "{{ ds }}"},
    )

    gold = atualizar_tabela(
        sql_path="transformation/gold/sales.sql",
        parametros={"data_agendamento": "{{ ds }}"},
    )

    dados >> bronze >> silver >> gold

dag_instance = dag_hello_goodbye()
