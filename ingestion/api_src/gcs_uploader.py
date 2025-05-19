import json
import logging
from datetime import datetime
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.exceptions import AirflowFailException

def save_json_to_gcs(bucket_name: str, folder: str, file_name: str, data: dict) -> str:
    gcs_path = f"{folder}/{file_name}"

    logging.info(f"Salvando arquivo {gcs_path} no bucket {bucket_name}")
    try:
        hook = GCSHook()
        hook.upload(
            bucket_name=bucket_name,
            object_name=gcs_path,
            data=json.dumps(data),
            mime_type='application/json'
        )
    except Exception as e:
        logging.error(f"Erro ao fazer upload no GCS: {str(e)}")
        raise AirflowFailException(f"Falha no upload para GCS: {str(e)}")

    return gcs_path
