import os

<<<<<<< HEAD
def read_parametized_sql(path: str, parameters: dict) -> str:
=======
def read_parametized_sql(path: str, parametros: dict) -> str:
    # Pega o diretório raiz do projeto, partindo do local do script
>>>>>>> 61bbb7a2205df012a8721c9d981e8803ad080043
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    full_path = os.path.join(base_dir, path)
    
    with open(full_path, 'r') as f:
        sql = f.read()
<<<<<<< HEAD
    for key, value in parameters.items():
=======
    for key, value in parametros.items():
>>>>>>> 61bbb7a2205df012a8721c9d981e8803ad080043
        sql = sql.replace(f"{{{key}}}", str(value))
    return sql
