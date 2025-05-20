
from datetime import datetime

from ingestion.api_src.api_reader import fetch_api_data
from ingestion.api_src.gcs_uploader import save_json_to_gcs
from transformation.python_scripts.read_sql_scripts import read_parametized_sql
import json
from google.cloud import bigquery




def extrair_e_salvar_json(data_agendamento: str, url: str, bucket_name: str, folder: str, end_file_name: str):
    subfolder = f"{folder}/{data_agendamento}"
    current_timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f"{current_timestamp}_{end_file_name}.json"
    with open('seuarquivo.json', 'r', encoding='utf-8') as f:
        vendas_json = json.load(f)
    #vendas_json = fetch_api_data(url)
    gcs_path = save_json_to_gcs(bucket_name, subfolder, file_name,vendas_json)

    return {
        "data_agendamento": data_agendamento,
        "folder": subfolder,
        "bucket": bucket_name,
        "file_path": gcs_path
    }

def task_atualizar_tabela(sql_path, params, location='US'):
    sql_final = read_parametized_sql(sql_path, params)

    # Cliente usa o project_id e as credenciais da variável de ambiente
    client = bigquery.Client()

    query_job = client.query(sql_final, location=location)
    result = query_job.result()

    print(f"Query executada com sucesso. {result.total_rows} linhas afetadas.")
    return result

# Tasks
dados = extrair_e_salvar_json(data_agendamento="2025-05-20",bucket_name = "seu-bucket-gcs",folder="vendas")

bronze = task_atualizar_tabela(
    "atualizar_bronze",
    "/transformation/bronze/sales.sql",
    {
        "data_agendamento": "{{ ds }}",
        "bucket": "{{ ti.xcom_pull(task_ids='extrair_e_salvar_json')['bucket'] }}",
        "folder": "{{ ti.xcom_pull(task_ids='extrair_e_salvar_json')['folder'] }}",
    },
)

silver = task_atualizar_tabela(
    "atualizar_silver",
    "/transformation/silver/sales.sql",
    {"data_agendamento": "{{ ds }}"},
)

gold = task_atualizar_tabela(
    "atualizar_gold",
    "/transformation/gold/sales.sql",
    {"data_agendamento": "{{ ds }}"},
)



