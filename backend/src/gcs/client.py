"""Google Cloud Storage client for handling file operations and presigned URLs."""

import os
import tempfile
from datetime import datetime, timedelta
from typing import Optional, Dict, Any, BinaryIO
from pathlib import Path

from google.cloud import storage
from google.cloud.exceptions import NotFound, Forbidden
from google.auth import impersonated_credentials
from google.auth import default
from pydantic import BaseModel


class PresignedUploadUrl(BaseModel):
    """Presigned URL response model."""
    upload_url: str
    file_path: str
    expires_at: datetime
    max_file_size_mb: int


class GCSClient:
    """Google Cloud Storage client for file operations."""
    
    def __init__(self):
        # Get default credentials and create impersonated credentials for signing
        source_credentials, project_id = default()
        
        # Service account email for impersonation
        service_account_email = os.getenv("GOOGLE_APPLICATION_CREDENTIALS_SERVICE_ACCOUNT") or f"pipeline-processor-dev@{project_id}.iam.gserviceaccount.com"
        
        # Create impersonated credentials for signing
        self.signing_credentials = impersonated_credentials.Credentials(
            source_credentials=source_credentials,
            target_principal=service_account_email,
            target_scopes=["https://www.googleapis.com/auth/cloud-platform"],
        )
        
        # Create storage client with regular credentials for operations
        self.client = storage.Client()
        
        self.input_bucket_name = os.getenv("GCS_INPUT_BUCKET")
        self.output_bucket_name = os.getenv("GCS_OUTPUT_BUCKET")
        self.temp_bucket_name = os.getenv("GCS_TEMP_BUCKET")
        
        if not self.input_bucket_name:
            raise ValueError("GCS_INPUT_BUCKET environment variable is required")
    
    def generate_presigned_upload_url(
        self,
        file_name: str,
        content_type: str,
        expires_in_minutes: int = 60,
        max_file_size_mb: int = 10,
        folder: str = "uploads"
    ) -> PresignedUploadUrl:
        """
        Generate a presigned URL for uploading files to GCS.
        
        Args:
            file_name: Name of the file to upload
            content_type: MIME type of the file
            expires_in_minutes: URL expiration time in minutes
            max_file_size_mb: Maximum allowed file size in MB
            folder: Folder path in the bucket
            
        Returns:
            PresignedUploadUrl object with upload details
        """
        bucket = self.client.bucket(self.input_bucket_name)
        
        # Generate timestamp-based file path to avoid conflicts
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        file_path = f"{folder}/{timestamp}_{file_name}"
        
        blob = bucket.blob(file_path)
        
        # Generate presigned URL for PUT operation
        expires_at = datetime.now() + timedelta(minutes=expires_in_minutes)
        
        # Use impersonated credentials for signing
        url = blob.generate_signed_url(
            version="v4",
            expiration=expires_at,
            method="PUT",
            content_type=content_type,
            credentials=self.signing_credentials,
            headers={
                "Content-Type": content_type,
                "Content-Length-Range": f"0,{max_file_size_mb * 1024 * 1024}"
            }
        )
        
        return PresignedUploadUrl(
            upload_url=url,
            file_path=file_path,
            expires_at=expires_at,
            max_file_size_mb=max_file_size_mb
        )
    
    def generate_presigned_download_url(
        self,
        file_path: str,
        expires_in_minutes: int = 60,
        bucket_name: Optional[str] = None
    ) -> str:
        """
        Generate a presigned URL for downloading files from GCS.
        
        Args:
            file_path: Path to the file in the bucket
            expires_in_minutes: URL expiration time in minutes
            bucket_name: Bucket name (defaults to output bucket)
            
        Returns:
            Presigned download URL
        """
        bucket_name = bucket_name or self.output_bucket_name
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(file_path)
        
        expires_at = datetime.now() + timedelta(minutes=expires_in_minutes)
        
        return blob.generate_signed_url(
            version="v4",
            expiration=expires_at,
            method="GET"
        )
    
    async def download_file(self, file_path: str, bucket_name: Optional[str] = None) -> bytes:
        """
        Download file content from GCS.
        
        Args:
            file_path: Path to the file in the bucket
            bucket_name: Bucket name (defaults to input bucket)
            
        Returns:
            File content as bytes
        """
        bucket_name = bucket_name or self.input_bucket_name
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(file_path)
        
        try:
            return blob.download_as_bytes()
        except NotFound:
            raise FileNotFoundError(f"File not found: {file_path}")
        except Forbidden:
            raise PermissionError(f"Access denied to file: {file_path}")
    
    async def upload_file(
        self,
        file_path: str,
        content: bytes,
        content_type: str = "application/octet-stream",
        bucket_name: Optional[str] = None
    ) -> str:
        """
        Upload file content to GCS.
        
        Args:
            file_path: Path where to store the file in the bucket
            content: File content as bytes
            content_type: MIME type of the file
            bucket_name: Bucket name (defaults to output bucket)
            
        Returns:
            GCS URI of the uploaded file
        """
        bucket_name = bucket_name or self.output_bucket_name
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(file_path)
        
        blob.upload_from_string(content, content_type=content_type)
        
        return f"gs://{bucket_name}/{file_path}"
    
    async def upload_file_from_path(
        self,
        local_file_path: str,
        gcs_file_path: str,
        bucket_name: Optional[str] = None
    ) -> str:
        """
        Upload file from local filesystem to GCS.
        
        Args:
            local_file_path: Path to local file
            gcs_file_path: Path where to store the file in GCS
            bucket_name: Bucket name (defaults to output bucket)
            
        Returns:
            GCS URI of the uploaded file
        """
        bucket_name = bucket_name or self.output_bucket_name
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(gcs_file_path)
        
        blob.upload_from_filename(local_file_path)
        
        return f"gs://{bucket_name}/{gcs_file_path}"
    
    async def list_files(
        self,
        prefix: str = "",
        bucket_name: Optional[str] = None,
        max_results: int = 1000
    ) -> list[str]:
        """
        List files in a GCS bucket.
        
        Args:
            prefix: Filter files by prefix
            bucket_name: Bucket name (defaults to input bucket)
            max_results: Maximum number of results to return
            
        Returns:
            List of file paths
        """
        bucket_name = bucket_name or self.input_bucket_name
        bucket = self.client.bucket(bucket_name)
        
        blobs = bucket.list_blobs(prefix=prefix, max_results=max_results)
        return [blob.name for blob in blobs]
    
    async def delete_file(self, file_path: str, bucket_name: Optional[str] = None) -> bool:
        """
        Delete a file from GCS.
        
        Args:
            file_path: Path to the file in the bucket
            bucket_name: Bucket name (defaults to input bucket)
            
        Returns:
            True if file was deleted, False if file didn't exist
        """
        bucket_name = bucket_name or self.input_bucket_name
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(file_path)
        
        try:
            blob.delete()
            return True
        except NotFound:
            return False
    
    async def file_exists(self, file_path: str, bucket_name: Optional[str] = None) -> bool:
        """
        Check if a file exists in GCS.
        
        Args:
            file_path: Path to the file in the bucket
            bucket_name: Bucket name (defaults to input bucket)
            
        Returns:
            True if file exists, False otherwise
        """
        bucket_name = bucket_name or self.input_bucket_name
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(file_path)
        
        return blob.exists()
    
    async def get_file_metadata(
        self,
        file_path: str,
        bucket_name: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Get metadata for a file in GCS.
        
        Args:
            file_path: Path to the file in the bucket
            bucket_name: Bucket name (defaults to input bucket)
            
        Returns:
            Dictionary containing file metadata
        """
        bucket_name = bucket_name or self.input_bucket_name
        bucket = self.client.bucket(bucket_name)
        blob = bucket.blob(file_path)
        
        try:
            blob.reload()
            return {
                "name": blob.name,
                "size": blob.size,
                "content_type": blob.content_type,
                "created": blob.time_created,
                "updated": blob.updated,
                "md5_hash": blob.md5_hash,
                "etag": blob.etag
            }
        except NotFound:
            raise FileNotFoundError(f"File not found: {file_path}")