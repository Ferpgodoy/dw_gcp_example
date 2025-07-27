import subprocess
from pathlib import Path
import base64
import sys

def main():
    terraform_dir = Path(__file__).resolve().parent.parent / "infra"

    # Executa o comando terraform para pegar o output que contém a chave em base64
    result = subprocess.run(
        ["terraform", "output", "-raw", "service_account_key_json"],
        cwd=terraform_dir,
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print("Erro ao rodar terraform output:", result.stderr, file=sys.stderr)
        sys.exit(1)

    key_b64 = result.stdout.strip()
    if not key_b64:
        print("Output terraform está vazio", file=sys.stderr)
        sys.exit(1)

    key_json_bytes = base64.b64decode(key_b64)

    # Caminho para salvar o arquivo json
    secrets_path = Path(__file__).resolve().parent.parent / "config" / "secrets"
    secrets_path.mkdir(parents=True, exist_ok=True)
    output_file = secrets_path / "gcp_credentials.json"

    with open(output_file, "wb") as f:
        f.write(key_json_bytes)

    print(f"Credencial salva em: {output_file}")

if __name__ == "__main__":
    main()
