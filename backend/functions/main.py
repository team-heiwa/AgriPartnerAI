"""Simple Cloud Function for testing."""

import functions_framework
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@functions_framework.cloud_event
def process_uploaded_file(cloud_event):
    """Simple file processor for testing."""
    try:
        data = cloud_event.data
        
        bucket_name = data.get('bucket', 'unknown')
        file_name = data.get('name', 'unknown')
        content_type = data.get('contentType', 'unknown')
        
        logger.info(f"Processing file: {file_name} from bucket: {bucket_name} (type: {content_type})")
        
        # Simple processing - just log the event
        result = {
            "status": "success",
            "file": file_name,
            "bucket": bucket_name,
            "content_type": content_type,
            "message": "File processed successfully"
        }
        
        logger.info(f"Successfully processed {file_name}")
        return result
        
    except Exception as e:
        logger.error(f"Error processing file: {str(e)}")
        return {"status": "error", "error": str(e)}