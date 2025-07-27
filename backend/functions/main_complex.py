"""Cloud Functions for AgriPartner AI processing pipeline."""

import os
import json
import logging
from typing import Dict, Any
import functions_framework

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize clients lazily to avoid startup issues
def get_storage_client():
    from google.cloud import storage
    return storage.Client()

def init_vertex_ai():
    from google.cloud import aiplatform
    aiplatform.init(
        project=os.environ.get('GCP_PROJECT_ID'),
        location=os.environ.get('VERTEX_AI_LOCATION', 'us-central1')
    )


@functions_framework.cloud_event
def process_uploaded_file(cloud_event):
    """Process files uploaded to the input bucket."""
    try:
        data = cloud_event.data
        
        bucket_name = data['bucket']
        file_name = data['name']
        content_type = data.get('contentType', '')
        
        logger.info(f"Processing file: {file_name} from bucket: {bucket_name}")
        
        # Get storage client
        storage_client = get_storage_client()
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(file_name)
        
        # Initialize Vertex AI
        init_vertex_ai()
        
        # Determine processing type based on content type
        if content_type.startswith('image/'):
            result = process_image(blob)
        elif content_type.startswith('audio/'):
            result = process_audio(blob)
        else:
            logger.warning(f"Unsupported content type: {content_type}")
            return {"status": "skipped", "reason": f"Unsupported content type: {content_type}"}
        
        # Save processed result to output bucket
        save_result(file_name, result, storage_client)
        
        logger.info(f"Successfully processed {file_name}")
        return {"status": "success", "file": file_name}
        
    except Exception as e:
        logger.error(f"Error processing file: {str(e)}")
        return {"status": "error", "error": str(e)}


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
                storage_client = get_storage_client()
                bucket = storage_client.bucket(bucket_name)
                blob = bucket.blob(file_name)
                
                # Process based on file extension or content type
                if file_name.lower().endswith(('.jpg', '.jpeg', '.png', '.gif')):
                    result = process_image(blob)
                elif file_name.lower().endswith(('.mp3', '.wav', '.m4a', '.ogg')):
                    result = process_audio(blob)
                else:
                    continue
                
                save_result(file_name, result, storage_client)
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


def process_image(blob) -> Dict[str, Any]:
    """Process an image file using Vertex AI Vision model."""
    try:
        import base64
        from vertexai.generative_models import GenerativeModel, Part
        
        # Download image data
        image_data = blob.download_as_bytes()
        
        # Initialize Vertex AI Gemini model
        model = GenerativeModel(
            model_name=os.environ.get('VERTEX_AI_MODEL', 'gemini-1.5-flash')
        )
        
        # Create image part
        image_part = Part.from_data(
            data=image_data,
            mime_type=blob.content_type or 'image/jpeg'
        )
        
        # Analyze image for agricultural purposes
        prompt = """
        この画像を農業の専門家として分析してください。以下の点について詳細に報告してください：

        1. 作物の種類と健康状態
        2. 病気や害虫の兆候
        3. 成長段階と収穫時期の予測
        4. 土壌や環境の状態
        5. 推奨される対策やアドバイス

        JSON形式で結果を返してください。
        """
        
        # Generate analysis
        response = model.generate_content([prompt, image_part])
        
        result = {
            'type': 'image',
            'file_name': blob.name,
            'size': len(image_data),
            'content_type': blob.content_type,
            'analysis': response.text,
            'model_used': os.environ.get('VERTEX_AI_MODEL', 'gemini-1.5-flash'),
            'timestamp': blob.time_created.isoformat() if blob.time_created else None
        }
        
        logger.info(f"Processed image with Vertex AI: {blob.name}")
        return result
        
    except Exception as e:
        logger.error(f"Error processing image {blob.name}: {str(e)}")
        raise


def process_audio(blob) -> Dict[str, Any]:
    """Process an audio file using Vertex AI Speech-to-Text and Gemini."""
    try:
        from google.cloud import speech
        from vertexai.generative_models import GenerativeModel
        
        # Download audio data
        audio_data = blob.download_as_bytes()
        
        # Initialize Speech-to-Text client
        speech_client = speech.SpeechClient()
        
        # Configure recognition
        audio = speech.RecognitionAudio(content=audio_data)
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.ENCODING_UNSPECIFIED,
            language_code="ja-JP",  # Japanese
            alternative_language_codes=["en-US"],  # English as fallback
            enable_automatic_punctuation=True,
        )
        
        # Perform speech-to-text
        response = speech_client.recognize(config=config, audio=audio)
        
        # Extract transcript
        transcript = ""
        for result in response.results:
            transcript += result.alternatives[0].transcript + " "
        
        if not transcript.strip():
            transcript = "音声の内容を認識できませんでした。"
        
        # Analyze transcript with Gemini
        model = GenerativeModel(
            model_name=os.environ.get('VERTEX_AI_MODEL', 'gemini-1.5-flash')
        )
        
        analysis_prompt = f"""
        以下の音声記録を農業の専門家として分析してください：

        音声内容: {transcript}

        以下の観点から分析して、JSON形式で返してください：
        1. 農業に関する内容の要約
        2. 識別された問題や課題
        3. 推奨される対策
        4. 重要度レベル（高/中/低）
        """
        
        analysis_response = model.generate_content(analysis_prompt)
        
        result = {
            'type': 'audio',
            'file_name': blob.name,
            'size': len(audio_data),
            'content_type': blob.content_type,
            'transcript': transcript.strip(),
            'analysis': analysis_response.text,
            'model_used': os.environ.get('VERTEX_AI_MODEL', 'gemini-1.5-flash'),
            'timestamp': blob.time_created.isoformat() if blob.time_created else None
        }
        
        logger.info(f"Processed audio with Speech-to-Text and Vertex AI: {blob.name}")
        return result
        
    except Exception as e:
        logger.error(f"Error processing audio {blob.name}: {str(e)}")
        raise


def save_result(original_file_name: str, result: Dict[str, Any], storage_client) -> None:
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