import os
from google.cloud import bigquery
from dotenv import load_dotenv
from read_sql_scripts import read_parametized_sql

# load environment variables from .env
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "../..", ".env"))

# Configs loaded
PROJECT_ID = os.getenv("GCP_PROJECT_ID")
DATASET_ID = "control"
CONTROL_TABLE = "executed_migrations"
SQL_DIRECTORY = os.path.abspath("migrations")

def create_control_table(client):

    # Checks if control table already exists INFORMATION_SCHEMA
    query = f"""
        SELECT COUNT(*) AS quantity
        FROM `{PROJECT_ID}.{DATASET_ID}.INFORMATION_SCHEMA.TABLES`
        WHERE table_name = '{CONTROL_TABLE}'
    """
    result = client.query(query).result()
    quantity = next(result).quantity 

    if quantity == 1:
        print(f"✔ Control table '{DATASET_ID}.{CONTROL_TABLE}' already exists in GCP.")
    else:
        ddl = f"""
            CREATE TABLE `{PROJECT_ID}.{DATASET_ID}.{CONTROL_TABLE}` (
                file_name STRING NOT NULL,
                execution_time TIMESTAMP NOT NULL
            )
        """
        client.query(ddl).result()
        print(f"✅ Control table '{DATASET_ID}.{CONTROL_TABLE}' successfully created.")


def get_executed_migrations(client):
    query = f"""
        SELECT file_name FROM `{PROJECT_ID}.{DATASET_ID}.{CONTROL_TABLE}`
    """
    result = client.query(query).result()
    return [row.file_name for row in result]

def register_migrations(client, file_name):
    query = f"""
        INSERT INTO `{PROJECT_ID}.{DATASET_ID}.{CONTROL_TABLE}` (file_name, execution_time)
        VALUES ('{file_name}', CURRENT_TIMESTAMP())
    """
    client.query(query).result()

def execute_migrations():
    client = bigquery.Client(project=PROJECT_ID)

    create_control_table(client)
    migrations_executed = get_executed_migrations(client)

    files = sorted(f for f in os.listdir(SQL_DIRECTORY) if f.endswith(".sql"))
    dict = {"PROJECT_ID": PROJECT_ID}
    for file in files:
        if file in migrations_executed:
            print(f"✔ Migration '{file}' already executed. skipping.")
            continue

        caminho = os.path.join(SQL_DIRECTORY, file)
        sql = read_parametized_sql(caminho,dict)

        print(f"⏳ executing migration '{file}'...")
        try:
            client.query(sql).result()
            register_migrations(client, file)
            print(f"Migration '{file}' successfully executed.")
        except Exception as e:
            print(f"ErroR executing '{file}': {e}")
            break

if __name__ == "__main__":
    execute_migrations()
