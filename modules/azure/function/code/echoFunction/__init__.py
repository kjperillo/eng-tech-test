import logging
import json
import azure.functions as func
from azure.storage.blob import BlobServiceClient
import os

def main(event: func.EventGridEvent):
    logging.info(f"Python EventGrid trigger function processed an event: {event.get_json()}")
    
    event_data = event.get_json()
    blob_url = event_data.get('url')
    
    if blob_url:
        # Extract storage account and blob information from the blob URL
        account_name = "techtesttargetsa"  # Change this to your storage account name
        account_key = os.environ['STORAGE_ACCOUNT_KEY']
        container_name = "tech-test-container"  # Change this to your container name
        blob_name = blob_url.split('/')[-1]

        try:
            # Initialize the BlobServiceClient
            blob_service_client = BlobServiceClient(
                account_url=f"https://{account_name}.blob.core.windows.net",
                credential=account_key
            )

            # Get the blob client
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
            
            # Download the blob content
            blob_content = blob_client.download_blob().readall()
            blob_text = blob_content.decode('utf-8')
            
            # Log the blob content
            logging.info(f"Blob Content: {blob_text}")
        
        except Exception as e:
            logging.error(f"Error reading blob content: {str(e)}")
    else:
        logging.warning("Blob URL not found in event data - wtf?")

# import logging
# import json
# import azure.functions as func

# def main(event: func.EventGridEvent):
#     logging.info(f"Python EventGrid trigger function processed an event: {event.get_json()}")
    
#     event_data = event.get_json()
#     blob_url = event_data.get('url')
    
#     if blob_url:
#         # Add your logic to read the blob content from the URL and log it
#         logging.info(f"Blob URL: {blob_url}")
#     else:
#         logging.warning("Blob URL not found in event data - wtf?")
