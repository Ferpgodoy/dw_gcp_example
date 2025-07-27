from airflow.decorators import task
from airflow.providers.google.cloud.hooks.bigquery import BigQueryHook
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.sdk import Variable
from datetime import datetime, timedelta
import logging
import pandas as pd
import tempfile
import os

from include.python_scripts.read_sql_scripts import read_parametized_sql

@task(
    retries=1,
    retry_delay=timedelta(minutes=5),
    execution_timeout=timedelta(minutes=30),
)
def extract_bigquery_to_gcs_xlsx(
    sql_path: str,
    data_type: str,
    parameters: dict,
    schedule_date: str
) -> dict:
    """
    Executa query no BigQuery a partir de arquivo SQL parametrizado, salva resultado em XLSX, e faz upload no GCS.

    Args:
        sql_path (str): Caminho do arquivo SQL a ser lido e parametrizado.
        parameters (dict): Dicionário com parâmetros para substituir no SQL.
        gcp_conn_id (str): ID da conexão GCP no Airflow.
        bucket_name (str): Nome do bucket GCS. Se None, pega variável Airflow 'GCP_BUCKET_NAME'.
        destination_folder (str): Pasta dentro do bucket para salvar o arquivo.

    Returns:
        dict: {'bucket': bucket_name, 'file_path': arquivo_no_bucket, 'schedule_date': ds}
    """

    bucket_name = Variable.get("GCP_BUCKET_NAME")

    destination_folder = f"exports/{data_type}/{schedule_date}"

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    file_name = f"bigquery_export_{timestamp}.xlsx"
    gcs_path = f"{destination_folder}/{file_name}"

    logging.info(f"Lendo e parametrizando SQL do arquivo {sql_path} com parâmetros {parameters}")
    sql_final = read_parametized_sql(sql_path, parameters)

    logging.info(f"Executando query no BigQuery")
    bq_hook = BigQueryHook(gcp_conn_id="GCP_CONN")
    client = bq_hook.get_client()

    rows = client.query(sql_final).result()

    df = rows.to_dataframe()
    if df.empty:
        raise ValueError("Consulta retornou dataframe vazio.")

    logging.info(f"Query retornou {len(df)} linhas. Salvando arquivo XLSX localmente.")

    with tempfile.TemporaryDirectory() as tmp_dir:
        local_path = os.path.join(tmp_dir, file_name)
        df.to_excel(local_path, index=False)

        logging.info(f"Arquivo salvo localmente em {local_path}. Enviando para GCS...")

        gcs_hook = GCSHook(gcp_conn_id="GCP_CONN")
        gcs_hook.upload(
            bucket_name=bucket_name,
            object_name=gcs_path,
            filename=local_path
        )

    logging.info(f"Arquivo enviado para gs://{bucket_name}/{gcs_path}")

    return {
        "bucket": bucket_name,
        "file_path": gcs_path,
        "schedule_date": schedule_date,
    }
