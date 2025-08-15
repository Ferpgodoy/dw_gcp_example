import subprocess
from pathlib import Path
import base64
import sys

def main():
    terraform_dir = Path(__file__).resolve().parent.parent / "infra"

    # Executes terraform commant to get output that contains GCP key in base64
    result = subprocess.run(
        ["terraform", "output", "-raw", "service_account_key_json"],
        cwd=terraform_dir,
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print("Error executing terraform output:", result.stderr, file=sys.stderr)
        sys.exit(1)

    key_b64 = result.stdout.strip()
    if not key_b64:
        print("Output terraform empty", file=sys.stderr)
        sys.exit(1)

    key_json_bytes = base64.b64decode(key_b64)

    # Path to save json file
    secrets_path = Path(__file__).resolve().parent.parent / "config" / "secrets"
    secrets_path.mkdir(parents=True, exist_ok=True)
    output_file = secrets_path / "gcp_credentials.json"

    with open(output_file, "wb") as f:
        f.write(key_json_bytes)

    print(f"Credential saved at: {output_file}")

if __name__ == "__main__":
    main()
