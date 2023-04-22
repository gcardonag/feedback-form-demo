import json
import logging
import base64
import uuid
from urllib.parse import parse_qs, urlencode

import boto3
from botocore.config import Config

logger = logging.getLogger()
logger.setLevel(logging.INFO)

boto3_config = Config(
    region_name = 'us-east-1',
    signature_version = 'v4',
    retries = {
        'max_attempts': 10,
        'mode': 'standard'
    }
)

ddb = boto3.client('dynamodb', config=boto3_config)
# table = ddb.Table("form-submit-nerts2023")

def lambda_handler(event, context):
    response = {
        'status': '200',
        'statusDescription': 'OK',
        'headers': {
            'cache-control': [
                {
                    'key': 'Cache-Control',
                    'value': 'max-age=100'
                }
            ],
            "content-type": [
                {
                    'key': 'Content-Type',
                    'value': 'application/json'
                }
            ]
        },
        'body': '{"message": "Thank you for your feedback! :)"}'
    }

    request = event['Records'][0]['cf']['request']
    print(request['headers'])
    if request['method'] == 'POST':
        body = base64.b64decode(request['body']['data'])
        decoded_body = json.loads(body)
        print(decoded_body)
        ddb.put_item(
            TableName = "form-submit-nerts2023",
            Item={
                'requestId': {
                    'S': str(uuid.uuid4()),
                },
                'name': {
                    'S': decoded_body.get("name", ""),
                },
                'experience': {
                    'S': decoded_body.get("experience", "N/A"),
                },
                'rating_101': {
                    'N': str(decoded_body.get("rating_101", 0)),
                },
                'rating_102': {
                    'N': str(decoded_body.get("rating_102", 0)),
                },
                'rating_103': {
                    'N': str(decoded_body.get("rating_103", 0)),
                },
                'memorable_notes': {
                    'S': decoded_body.get("memorable_notes", "N/A"),
                },
                'additional_notes': {
                    'S': decoded_body.get("additional_notes", "N/A"),
                },
            }
        )
        return response
    else:
        raise Exception("Invalid request method")
