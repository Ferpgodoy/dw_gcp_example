import os
from dotenv import load_dotenv
from google.cloud import storage
import sys

# Load environment variables from .env file
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), "..", ".env"))

# Loaded configuration
PROJECT_ID = os.getenv("GCP_PROJECT_ID")
GCP_BUCKET_NAME = os.getenv("GCP_BUCKET_NAME")

def delete_all_blobs(bucket_name, prefix=None):
    client = storage.Client()
    bucket = client.bucket(bucket_name)

    blobs = list(client.list_blobs(bucket, prefix=prefix))
    if not blobs:
        if prefix:
            print(f"No files found with prefix '{prefix}' in bucket '{bucket_name}'.")
        else:
            print(f"No files found in bucket '{bucket_name}'.")
        return

    if prefix:
        print(f"Deleting {len(blobs)} files with prefix '{prefix}' from bucket '{bucket_name}'...")
    else:
        print(f"Deleting {len(blobs)} files from bucket '{bucket_name}'...")

    for blob in blobs:
        print(f"Deleting: {blob.name}")
        blob.delete()

    print("Deletion completed.")

if __name__ == "__main__":
    if not PROJECT_ID or not GCP_BUCKET_NAME:
        print("Error: Make sure GCP_PROJECT_ID and GCP_BUCKET_NAME environment variables are set.")
        sys.exit(1)

    prefix = None
    if len(sys.argv) > 1:
        prefix = sys.argv[1]

    delete_all_blobs(GCP_BUCKET_NAME, prefix)
