import subprocess
from pathlib import Path
import sys

def main():
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent

    secrets_dir = project_root / "config" / "secrets"
    secrets_dir.mkdir(parents=True, exist_ok=True)

    output_file = secrets_dir / "gcp_credentials.json"

    # remove older file if exists
    if output_file.exists():
        output_file.unlink()

    terraform_dir = project_root / "terraform"
    result = subprocess.run(
        ["terraform", "output", "-raw", "service_account_email"],
        cwd=terraform_dir,
        capture_output=True,
        text=True
    )

    service_account_email = result.stdout.strip()
    if not service_account_email:
        print("Error: Terraform output 'service_account_email' is empty.", file=sys.stderr)
        sys.exit(1)

    cmd = [
        "gcloud", "iam", "service-accounts", "keys", "create", str(output_file),
        "--iam-account", service_account_email
    ]

    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error executing command gcloud: {e}", file=sys.stderr)
        sys.exit(1)

    if output_file.exists():
        print(f"Credentials file succesfully created at: {output_file}")
    else:
        print(f"Error creating Credentials file at: {output_file}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
