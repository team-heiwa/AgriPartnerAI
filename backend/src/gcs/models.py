"""Data models for GCS operations."""

from datetime import datetime
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field
from enum import Enum


class MediaType(str, Enum):
    """Supported media types."""
    IMAGE = "image"
    AUDIO = "audio"




class UploadRequest(BaseModel):
    """Request model for generating presigned upload URL."""
    file_name: str = Field(..., description="Name of the file to upload")
    content_type: str = Field(..., description="MIME type of the file")
    media_type: MediaType = Field(..., description="Type of media (image/audio)")
    folder: str = Field(default="uploads", description="Folder path in bucket")
    expires_in_minutes: int = Field(default=60, ge=1, le=1440, description="URL expiration in minutes")
    max_file_size_mb: int = Field(default=10, ge=1, le=100, description="Maximum file size in MB")


class UploadResponse(BaseModel):
    """Response model for presigned upload URL."""
    upload_url: str = Field(..., description="Presigned URL for uploading")
    file_path: str = Field(..., description="File path in GCS bucket")
    expires_at: datetime = Field(..., description="URL expiration timestamp")
    max_file_size_mb: int = Field(..., description="Maximum allowed file size in MB")
    upload_instructions: Dict[str, Any] = Field(
        default_factory=lambda: {
            "method": "PUT",
            "headers": {
                "Content-Type": "Must match the specified content_type"
            },
            "notes": [
                "File size must not exceed max_file_size_mb",
                "Content-Type header is required and must match",
                "URL expires at the specified time"
            ]
        }
    )




