from airflow.decorators import dag, task
from datetime import datetime
import os
import json
import logging


@dag(
    start_date=datetime(2024, 1, 1),
    schedule=None,
    catchup=False,
    tags=["utility", "gcp"],
)
def copy_gcp_credentials_dag():

    @task
    def copy_credentials():
        creds_json = os.getenv("GOOGLE_APPLICATION_CREDENTIALS_JSON")

        if not creds_json:
            raise ValueError("Variável de ambiente 'GOOGLE_APPLICATION_CREDENTIALS_JSON' não encontrada.")

        try:
            creds_dict = json.loads(creds_json)
        except json.JSONDecodeError as e:
            logging.error("Erro ao decodificar JSON da variável de ambiente.")
            raise e

        # Resolve para: <raiz_do_projeto>/config/secrets/gcp_credentials.json
        output_path = os.path.join(os.path.dirname(__file__), "..", "config", "secrets", "gcp_credentials1.json")
        output_path = os.path.abspath(output_path)
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        with open(output_path, "w") as f:
            json.dump(creds_dict, f, indent=2)

        logging.info(f"Credenciais salvas com sucesso em {output_path}.")

    copy_credentials()


dag_instance = copy_gcp_credentials_dag()