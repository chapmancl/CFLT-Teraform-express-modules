import json
import boto3
import logging
from botocore.exceptions import ClientError


def access_secret_version(secret_id, version_id="latest", region_name="us-east-2"):
    jobj = {}
    try:
        # Create a Secrets Manager client
        session = boto3.session.Session()
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name
        )
        try:
            get_secret_value_response = client.get_secret_value(
                SecretId=secret_id
            )
        except ClientError as ce:
            # For a list of exceptions thrown, see
            # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
            logging.exception(ce)
        except Exception as e:
            logging.exception(e)
        # Decrypts secret using the associated KMS key.
        secret = get_secret_value_response['SecretString']
        
        # Return the decoded payload.
        jobj = json.loads(secret)
    except Exception as e:
        logging.exception(e)
    
    return jobj