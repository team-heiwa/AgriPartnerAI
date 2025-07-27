"""Cloud Functions for AgriPartner AI processing pipeline."""

import os
import json
import logging
from google.cloud import storage
from google.cloud import aiplatform
from typing import Dict, Any
import functions_framework

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize GCP clients
storage_client = storage.Client()
aiplatform.init(
    project=os.environ.get('GCP_PROJECT_ID'),
    location=os.environ.get('VERTEX_AI_LOCATION', 'us-central1')
)


@functions_framework.cloud_event
def process_uploaded_file(cloud_event):
    """Process files uploaded to the input bucket."""
    data = cloud_event.data
    
    bucket_name = data['bucket']
    file_name = data['name']
    content_type = data.get('contentType', '')
    
    logger.info(f"Processing file: {file_name} from bucket: {bucket_name}")
    
    try:
        # Get the uploaded file
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        
        # Determine processing type based on content type
        if content_type.startswith('image/'):
            result = process_image(blob)
        elif content_type.startswith('audio/'):
            result = process_audio(blob)
        else:
            logger.warning(f"Unsupported content type: {content_type}")
            return
        
        # Save processed result to output bucket
        save_result(file_name, result)
        
        logger.info(f"Successfully processed {file_name}")
        
    except Exception as e:
        logger.error(f"Error processing {file_name}: {str(e)}")
        raise


@functions_framework.http
def process_batch(request):
    """Process multiple files in batch."""
    try:
        request_json = request.get_json(silent=True)
        if not request_json or 'files' not in request_json:
            return {'error': 'Invalid request format'}, 400
        
        files = request_json['files']
        results = []
        
        for file_info in files:
            bucket_name = file_info.get('bucket')
            file_name = file_info.get('name')
            
            if not bucket_name or not file_name:
                continue
                
            try:
                bucket = storage_client.bucket(bucket_name)
                blob = bucket.blob(file_name)
                
                # Process based on file extension or content type
                if file_name.lower().endswith(('.jpg', '.jpeg', '.png', '.gif')):
                    result = process_image(blob)
                elif file_name.lower().endswith(('.mp3', '.wav', '.m4a', '.ogg')):
                    result = process_audio(blob)
                else:
                    continue
                
                save_result(file_name, result)
                results.append({
                    'file': file_name,
                    'status': 'success',
                    'result': result
                })
                
            except Exception as e:
                logger.error(f"Error processing {file_name}: {str(e)}")
                results.append({
                    'file': file_name,
                    'status': 'error',
                    'error': str(e)
                })
        
        return {'results': results}, 200
        
    except Exception as e:
        logger.error(f"Batch processing error: {str(e)}")
        return {'error': str(e)}, 500


def process_image(blob: storage.Blob) -> Dict[str, Any]:
    """Process an image file using Vertex AI."""
    try:
        # Download image data
        image_data = blob.download_as_bytes()
        
        # TODO: Implement actual image processing with Vertex AI
        # For now, return placeholder result
        result = {
            'type': 'image',
            'file_name': blob.name,
            'size': len(image_data),
            'analysis': 'Image analysis placeholder - to be implemented',
            'timestamp': blob.time_created.isoformat() if blob.time_created else None
        }
        
        logger.info(f"Processed image: {blob.name}")
        return result
        
    except Exception as e:
        logger.error(f"Error processing image {blob.name}: {str(e)}")
        raise


def process_audio(blob: storage.Blob) -> Dict[str, Any]:
    """Process an audio file using Vertex AI."""
    try:
        # Download audio data
        audio_data = blob.download_as_bytes()
        
        # TODO: Implement actual audio processing with Vertex AI
        # For now, return placeholder result
        result = {
            'type': 'audio',
            'file_name': blob.name,
            'size': len(audio_data),
            'analysis': 'Audio analysis placeholder - to be implemented',
            'timestamp': blob.time_created.isoformat() if blob.time_created else None
        }
        
        logger.info(f"Processed audio: {blob.name}")
        return result
        
    except Exception as e:
        logger.error(f"Error processing audio {blob.name}: {str(e)}")
        raise


def save_result(original_file_name: str, result: Dict[str, Any]) -> None:
    """Save processing result to output bucket."""
    try:
        output_bucket_name = os.environ.get('GCS_OUTPUT_BUCKET')
        if not output_bucket_name:
            raise ValueError("GCS_OUTPUT_BUCKET environment variable not set")
        
        output_bucket = storage_client.bucket(output_bucket_name)
        
        # Create output file name
        base_name = os.path.splitext(original_file_name)[0]
        output_file_name = f"{base_name}_processed.json"
        
        # Save result as JSON
        output_blob = output_bucket.blob(output_file_name)
        output_blob.upload_from_string(
            json.dumps(result, indent=2),
            content_type='application/json'
        )
        
        logger.info(f"Saved result to: {output_file_name}")
        
    except Exception as e:
        logger.error(f"Error saving result for {original_file_name}: {str(e)}")
        raise