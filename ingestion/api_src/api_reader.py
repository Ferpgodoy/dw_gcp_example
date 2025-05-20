import logging
import requests

def fetch_api_data(url: str) -> dict:
    logging.info(f"Consultando API: {url}")
    response = requests.get(url)
    logging.info(f"Status code: {response.status_code}")

    if response.status_code != 200:
        raise Exception(f"Erro ao consultar API: {response.status_code} - {response.text}")

    try:
        return response.json()
    except Exception as e:
        raise Exception(f"Erro ao decodificar JSON: {str(e)}")

