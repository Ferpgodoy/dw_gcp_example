from airflow.decorators import task
from airflow.operators.python import get_current_context
from airflow.providers.google.cloud.hooks.gcs import GCSHook
from airflow.sdk import Variable
from datetime import datetime, timedelta
import logging

from include.python_scripts.generate_fake_data import generate_sales, generate_product_reviews, generate_site_sessions
from include.python_scripts.gcs_uploader import save_json_to_gcs
from include.python_scripts.api_reader import fetch_api_data

@task(
    retries=1,
    retry_delay=timedelta(minutes=5),
    execution_timeout=timedelta(minutes=30),
)
def extract_and_save_json(data_type: str, url: str = None) -> dict:

    data_types = {
        "sales": generate_sales,
        "product_reviews": generate_product_reviews,
        "site_sessions": generate_site_sessions
    }

    if data_type not in data_types:
        raise ValueError(f"Invalid data type: {data_type}. Expected one of {list(data_types.keys())}.")

    context = get_current_context()
    schedule_date = context['ds']
    row_count = context['params']['row_count']
    
    bucket_name = Variable.get("GCP_BUCKET_NAME")

    folder = data_type
    subfolder = f"{folder}/{schedule_date}"
    current_timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    file_name = f"{current_timestamp}.json"

    logging.info(f"Generating fake {data_type} data for {schedule_date} with {row_count} rows.")

    # If you want to fetch from an API, uncomment the next line and comment the json generation line
    # json = fetch_api_data(url=url, method='GET', headers=None, body=None, timeout=10)

    json = data_types[data_type](schedule_date, count=row_count)

    if not json:
        raise ValueError(f"No {data_type} data generated/obtained.")

    # Try GCSHook first (works on Astronomer Cloud)
    gcs_client = GCSHook(gcp_conn_id="GCP_CONN").get_conn()

    gcs_path = save_json_to_gcs(bucket_name, subfolder, file_name, json, gcs_client)

    return {"bucket": bucket_name, "file_path": gcs_path, "schedule_date": schedule_date}