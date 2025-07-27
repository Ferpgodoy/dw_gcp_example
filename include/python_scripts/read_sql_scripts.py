import os
import inspect

def read_parametized_sql(path: str, parameters: dict) -> str:
    # Get the frame of the function that called this one
    caller_frame = inspect.stack()[1]
    caller_file = caller_frame.filename
    caller_dir = os.path.dirname(os.path.abspath(caller_file))

    # Build the full path to the SQL file based on the caller's location
    full_path = os.path.join(caller_dir, path)

    # Validate if the file exists
    if not os.path.exists(full_path):
        raise FileNotFoundError(f"SQL file not found: {full_path}")

    # Read the SQL file content
    with open(full_path, 'r') as f:
        sql = f.read()

    # Replace placeholders with provided parameters
    for key, value in parameters.items():
        sql = sql.replace(f"{{{key}}}", str(value))

    return sql
