import os
import requests
from dotenv import load_dotenv
import pandas as pd

# Carrega variáveis de ambiente do arquivo config/.env
load_dotenv(dotenv_path="config/.env")

# Lê as variáveis do .env
BASE_URL = os.getenv("API_FUTEBOL_BASE_URL")
API_KEY = os.getenv("API_FUTEBOL_KEY")

# Define headers com a chave da API
headers = {
    "Authorization": f"Bearer {API_KEY}"
}

# Exemplo de endpoint: lista de campeonatos
def get_campeonatos(campeonato_id):
    url = f"{BASE_URL}/campeonatos/{campeonato_id}/partidas"
    response = requests.get(url, headers=headers)

    if response.status_code == 200:
        return response.json()
    else:
        print(f"Erro: {response.status_code}")
        print(response.text)
        return None

if __name__ == "__main__":
    campeonato_id = 14
    dados = get_campeonatos(campeonato_id)
    if dados:
        print(dados)
        # Converte o JSON para DataFrame
        df = pd.DataFrame(dados)

        # Define o caminho da pasta do script atual
        current_dir = os.path.dirname(os.path.abspath(__file__))

        # Define o nome do arquivo CSV
        json_file_path = os.path.join(current_dir, "resultado.json")

        # Salva o DataFrame em CSV
        df.to_json(json_file_path, index=False)

        print(f"Arquivo JSON salvo em: {json_file_path}")
