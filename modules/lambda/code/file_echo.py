import json
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3_client = boto3.client('s3')

def lambda_handler(event, context):
    for record in event['Records']:
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        # Get the file content
        try:
            response = s3_client.get_object(Bucket=bucket_name, Key=object_key)
            file_content = response['Body'].read().decode('utf-8')
            logger.info(f"File content of {object_key}: {file_content}")
        except Exception as e:
            logger.error(f"Error reading object {object_key} from bucket {bucket_name}. Error: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Function executed successfully')
    }