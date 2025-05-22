import os

def read_parametized_sql(path: str, parameters: dict) -> str:
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    full_path = os.path.join(base_dir, path)
    
    with open(full_path, 'r') as f:
        sql = f.read()
    for key, value in parameters.items():
        sql = sql.replace(f"{{{key}}}", str(value))
    return sql
