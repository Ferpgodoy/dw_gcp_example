import json
import logging
from google.cloud import storage

def save_json_to_gcs(bucket_name: str, folder: str, file_name: str, data: dict) -> str:
    gcs_path = f"{folder}/{file_name}"

    logging.info(f"Salvando arquivo {gcs_path} no bucket {bucket_name}")
    try:
        client = storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(gcs_path)
        json_data = '\n'.join(json.dumps(row) for row in data)
        blob.upload_from_string(json_data, content_type='application/json')
    except Exception as e:
        logging.error(f"Erro ao fazer upload no GCS: {str(e)}")
        raise

    return gcs_path
