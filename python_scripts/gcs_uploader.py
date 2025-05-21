import io
import json
import logging
from typing import Optional, Union
import pandas as pd
from google.cloud import storage

def save_json_to_gcs(
    bucket_name: str,
    folder: str,
    file_name: str,
    data: Union[dict, list],
    client: Optional[storage.Client] = None
) -> str:
    """
    Salva dados JSON no Google Cloud Storage.
    `data` pode ser um dict ou uma lista de dicts.
    """
    gcs_path = f"{folder}/{file_name}"
    logging.info(f"Salvando arquivo JSON {gcs_path} no bucket {bucket_name}")

    try:
        client = client or storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(gcs_path)
        
        # Se for lista, grava cada item como JSON em linha separada (JSON Lines)
        if isinstance(data, list):
            json_data = '\n'.join(json.dumps(row) for row in data)
        else:
            json_data = json.dumps(data)
            
        blob.upload_from_string(json_data, content_type='application/json')
    except Exception as e:
        logging.error(f"Erro ao fazer upload JSON no GCS: {str(e)}")
        raise

    return gcs_path


def save_csv_to_gcs(
    bucket_name: str,
    folder: str,
    file_name: str,
    df: pd.DataFrame,
    client: Optional[storage.Client] = None
) -> str:
    gcs_path = f"{folder}/{file_name}"
    logging.info(f"Salvando arquivo CSV {gcs_path} no bucket {bucket_name}")

    try:
        client = client or storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(gcs_path)

        csv_buffer = io.StringIO()
        df.to_csv(csv_buffer, index=False)
        blob.upload_from_string(csv_buffer.getvalue(), content_type='text/csv')

    except Exception as e:
        logging.error(f"Erro ao fazer upload CSV no GCS: {str(e)}")
        raise

    return gcs_path


def save_xlsx_to_gcs(
    bucket_name: str,
    folder: str,
    file_name: str,
    df: pd.DataFrame,
    client: Optional[storage.Client] = None
) -> str:
    gcs_path = f"{folder}/{file_name}"
    logging.info(f"Salvando arquivo XLSX {gcs_path} no bucket {bucket_name}")

    try:
        client = client or storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(gcs_path)

        excel_buffer = io.BytesIO()
        with pd.ExcelWriter(excel_buffer, engine='openpyxl') as writer:
            df.to_excel(writer, index=False)
        blob.upload_from_string(excel_buffer.getvalue(), content_type='application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

    except Exception as e:
        logging.error(f"Erro ao fazer upload XLSX no GCS: {str(e)}")
        raise

    return gcs_path


def save_parquet_to_gcs(
    bucket_name: str,
    folder: str,
    file_name: str,
    df: pd.DataFrame,
    client: Optional[storage.Client] = None
) -> str:
    gcs_path = f"{folder}/{file_name}"
    logging.info(f"Salvando arquivo Parquet {gcs_path} no bucket {bucket_name}")

    try:
        client = client or storage.Client()
        bucket = client.bucket(bucket_name)
        blob = bucket.blob(gcs_path)

        parquet_buffer = io.BytesIO()
        df.to_parquet(parquet_buffer, index=False)
        blob.upload_from_string(parquet_buffer.getvalue(), content_type='application/octet-stream')

    except Exception as e:
        logging.error(f"Erro ao fazer upload Parquet no GCS: {str(e)}")
        raise

    return gcs_path
