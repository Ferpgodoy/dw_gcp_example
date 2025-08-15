import logging
import requests
from typing import Optional

def fetch_api_data(
    url: str,
    method: str = 'GET',
    headers: Optional[dict] = None,
    body: Optional[dict] = None,
    timeout: int = 10
) -> dict:
    logging.info(f"{method.upper()} Request to API: {url}")

    try:
        response = requests.request(
            method=method.upper(),
            url=url,
            headers=headers,
            json=body,
            timeout=timeout
        )

        logging.info(f"Status code: {response.status_code}")
        response.raise_for_status()
        return response.json()

    except requests.RequestException as e:
        logging.error(f"HTTP Request error: {str(e)}")
        raise

    except ValueError as e:
        logging.error(f"Error reading JSON: {str(e)}")
        raise

