"""API endpoints for file upload operations."""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import ValidationError

from src.gcs.client import GCSClient
from src.gcs.models import (
    UploadRequest,
    UploadResponse,
    MediaType
)


router = APIRouter(prefix="/upload", tags=["upload"])


def get_gcs_client() -> GCSClient:
    """Dependency to get GCS client instance."""
    return GCSClient()


@router.post("/presigned-url", response_model=UploadResponse)
async def generate_upload_url(
    request: UploadRequest,
    gcs_client: GCSClient = Depends(get_gcs_client)
):
    """
    Generate a presigned URL for file upload.
    
    This endpoint creates a presigned URL that allows clients to upload files
    directly to Google Cloud Storage without going through the backend server.
    """
    try:
        # Validate content type based on media type
        if request.media_type == MediaType.IMAGE:
            if not request.content_type.startswith("image/"):
                raise HTTPException(
                    status_code=400,
                    detail="Content type must be an image type for image media"
                )
        elif request.media_type == MediaType.AUDIO:
            if not (request.content_type.startswith("audio/") or 
                   request.content_type in ["video/mp4", "video/quicktime"]):
                raise HTTPException(
                    status_code=400,
                    detail="Content type must be an audio or video type for audio media"
                )
        
        # Generate presigned URL
        presigned_url = gcs_client.generate_presigned_upload_url(
            file_name=request.file_name,
            content_type=request.content_type,
            expires_in_minutes=request.expires_in_minutes,
            max_file_size_mb=request.max_file_size_mb,
            folder=f"{request.media_type.value}s/{request.folder}"
        )
        
        return UploadResponse(
            upload_url=presigned_url.upload_url,
            file_path=presigned_url.file_path,
            expires_at=presigned_url.expires_at,
            max_file_size_mb=presigned_url.max_file_size_mb
        )
        
    except ValidationError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate upload URL: {str(e)}")


