#!/usr/bin/env python3
"""Simple example for using GCS presigned URL upload functionality."""

import asyncio
import aiohttp


async def simple_upload_example():
    """Simple example of uploading a file using presigned URL."""
    
    # 1. Request presigned URL from API
    upload_request = {
        "file_name": "sample_image.jpg",
        "content_type": "image/jpeg",
        "media_type": "image",
        "folder": "examples",
        "expires_in_minutes": 30,
        "max_file_size_mb": 5
    }
    
    async with aiohttp.ClientSession() as session:
        # Get presigned URL
        print("Requesting presigned URL...")
        async with session.post(
            "http://localhost:8080/upload/presigned-url",
            json=upload_request
        ) as response:
            if response.status != 200:
                error_text = await response.text()
                print(f"❌ Failed to get presigned URL: {error_text}")
                return
            
            upload_response = await response.json()
            print("✅ Presigned URL generated:")
            print(f"   File path: {upload_response['file_path']}")
            print(f"   Expires at: {upload_response['expires_at']}")
        
        # 2. Upload file using presigned URL
        print("\nUploading file...")
        sample_content = b"This is a sample image file content"
        
        async with session.put(
            upload_response["upload_url"],
            data=sample_content,
            headers={"Content-Type": upload_request["content_type"]}
        ) as upload_resp:
            if upload_resp.status in [200, 201]:
                print("✅ File uploaded successfully!")
                print(f"   File is now available at: {upload_response['file_path']}")
            else:
                error_text = await upload_resp.text()
                print(f"❌ Upload failed: {error_text}")


async def main():
    """Run the example."""
    print("=== Simple GCS Presigned URL Upload Example ===\n")
    
    try:
        await simple_upload_example()
    except aiohttp.ClientError as e:
        print(f"❌ Connection error: {e}")
        print("   Make sure the API server is running on http://localhost:8080")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")


if __name__ == "__main__":
    print("Starting simple upload example...")
    print("Make sure the API server is running: uv run python src/api/main.py")
    print("Press Ctrl+C to cancel\n")
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n👋 Example cancelled by user")
    except Exception as e:
        print(f"\n❌ Error: {e}")