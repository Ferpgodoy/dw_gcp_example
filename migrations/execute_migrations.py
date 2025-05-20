import os
from google.cloud import bigquery
from dotenv import load_dotenv

# Carrega variáveis de ambiente do .env
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# Configurações carregadas do .env
PROJECT_ID = os.getenv("GCP_PROJECT_ID")
DATASET_ID = os.getenv("BQ_DATASET")
TABELA_CONTROLE = os.getenv("BQ_MIGRATION_TABLE")
PASTA_SQL = os.path.join(os.path.dirname(__file__), "sql_scripts")

def criar_tabela_controle(client):

    # Verifica se a tabela existe usando INFORMATION_SCHEMA
    query = f"""
        SELECT COUNT(*) AS qtd
        FROM `{PROJECT_ID}.{DATASET_ID}.INFORMATION_SCHEMA.TABLES`
        WHERE table_name = '{TABELA_CONTROLE}'
    """
    result = client.query(query).result()
    qtd = next(result).qtd  # Pega o valor da contagem

    if qtd == 1:
        print(f"✔ Tabela de controle '{DATASET_ID}.{TABELA_CONTROLE}' já existe.")
    else:
        ddl = f"""
            CREATE TABLE `{PROJECT_ID}.{DATASET_ID}.{TABELA_CONTROLE}` (
                file_name STRING NOT NULL,
                execution_time TIMESTAMP NOT NULL
            )
        """
        client.query(ddl).result()
        print(f"✅ Tabela de controle '{DATASET_ID}.{TABELA_CONTROLE}' criada com sucesso.")


def obter_migrations_executadas(client):
    query = f"""
        SELECT file_name FROM `{PROJECT_ID}.{DATASET_ID}.{TABELA_CONTROLE}`
    """
    result = client.query(query).result()
    return [row.file_name for row in result]

def registrar_migration(client, file_name):
    query = f"""
        INSERT INTO `{PROJECT_ID}.{DATASET_ID}.{TABELA_CONTROLE}` (file_name, execution_time)
        VALUES ('{file_name}', CURRENT_TIMESTAMP())
    """
    client.query(query).result()

def executar_migrations():
    client = bigquery.Client(project=PROJECT_ID)

    criar_tabela_controle(client)
    executados = obter_migrations_executadas(client)

    arquivos = sorted(f for f in os.listdir(PASTA_SQL) if f.endswith(".sql"))
    for arquivo in arquivos:
        if arquivo in executados:
            print(f"✔ Migration '{arquivo}' já executada. Pulando.")
            continue

        caminho = os.path.join(PASTA_SQL, arquivo)
        with open(caminho, "r", encoding="utf-8") as f:
            sql = f.read()

        print(f"⏳ Executando migration '{arquivo}'...")
        try:
            client.query(sql).result()
            registrar_migration(client, arquivo)
            print(f"Migration '{arquivo}' executada com sucesso.")
        except Exception as e:
            print(f"Erro ao executar '{arquivo}': {e}")
            break

if __name__ == "__main__":
    executar_migrations()
