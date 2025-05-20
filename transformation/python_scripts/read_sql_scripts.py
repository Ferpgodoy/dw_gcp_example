def read_parametized_sql(path: str, params: dict) -> str:
    with open(path, 'r') as f:
        sql = f.read()
    for key, value in params.items():
        placeholder = f"{{{key}}}" # ex: {data_agendamento}
        sql = sql.replace(placeholder, f"'{value}'")
    return sql
