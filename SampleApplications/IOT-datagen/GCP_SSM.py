import json
from google.cloud import secretmanager

def access_secret_version(secret_id, gcp_project, version_id="latest"):
    # Create the Secret Manager client.
    client = secretmanager.SecretManagerServiceClient()
    # Build the resource name of the secret version.
    name = f"projects/{gcp_project}/secrets/{secret_id}/versions/{version_id}"
    # Access the secret version.
    response = client.access_secret_version(name=name)
    # Return the decoded payload.
    jobj = json.loads(response.payload.data.decode('UTF-8'))
    return jobj