import logging
import json
import azure.functions as func

def main(event: func.EventGridEvent):
    logging.info(f"Python EventGrid trigger function processed an event: {event.get_json()}")
    
    event_data = event.get_json()
    blob_url = event_data.get('url')
    
    if blob_url:
        # Add your logic to read the blob content from the URL and log it
        logging.info(f"Blob URL: {blob_url}")
    else:
        logging.warning("Blob URL not found in event data - wtf?")
