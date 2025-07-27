#!/usr/bin/env python3
"""Example for uploading audio files using presigned URL."""

import asyncio
import aiohttp


async def upload_audio_file():
    """Example of uploading an audio file."""
    
    # MP3ファイルのアップロード例
    upload_request = {
        "file_name": "sample_audio.mp3",
        "content_type": "audio/mpeg",
        "media_type": "audio",
        "folder": "audio_examples",
        "expires_in_minutes": 30,
        "max_file_size_mb": 50  # 音声ファイルは大きめに設定
    }
    
    async with aiohttp.ClientSession() as session:
        print("🎵 Requesting presigned URL for audio upload...")
        
        async with session.post(
            "http://localhost:8080/upload/presigned-url",
            json=upload_request
        ) as response:
            if response.status != 200:
                error_text = await response.text()
                print(f"❌ Failed to get presigned URL: {error_text}")
                return
            
            upload_response = await response.json()
            print("✅ Audio presigned URL generated:")
            print(f"   File path: {upload_response['file_path']}")
            print(f"   Max size: {upload_response['max_file_size_mb']}MB")
            print(f"   Expires at: {upload_response['expires_at']}")
        
        # サンプル音声データをアップロード
        print("\n🎵 Uploading audio file...")
        sample_audio_content = b"Sample audio file content (would be actual audio bytes)"
        
        async with session.put(
            upload_response["upload_url"],
            data=sample_audio_content,
            headers={"Content-Type": upload_request["content_type"]}
        ) as upload_resp:
            if upload_resp.status in [200, 201]:
                print("✅ Audio file uploaded successfully!")
                print(f"   Audio file available at: {upload_response['file_path']}")
            else:
                error_text = await upload_resp.text()
                print(f"❌ Audio upload failed: {error_text}")


async def upload_different_audio_formats():
    """Examples of different audio format uploads."""
    
    audio_formats = [
        {
            "file_name": "recording.mp3",
            "content_type": "audio/mpeg",
            "description": "MP3音声ファイル"
        },
        {
            "file_name": "voice_memo.wav", 
            "content_type": "audio/wav",
            "description": "WAV音声ファイル"
        },
        {
            "file_name": "podcast.m4a",
            "content_type": "audio/mp4", 
            "description": "M4A音声ファイル"
        },
        {
            "file_name": "interview.mp4",
            "content_type": "video/mp4",
            "description": "MP4動画ファイル（音声抽出用）"
        }
    ]
    
    async with aiohttp.ClientSession() as session:
        for audio_format in audio_formats:
            print(f"\n🎵 Testing upload for: {audio_format['description']}")
            
            upload_request = {
                "file_name": audio_format["file_name"],
                "content_type": audio_format["content_type"],
                "media_type": "audio",
                "folder": "format_tests",
                "max_file_size_mb": 100
            }
            
            async with session.post(
                "http://localhost:8080/upload/presigned-url",
                json=upload_request
            ) as response:
                if response.status == 200:
                    upload_response = await response.json()
                    print(f"   ✅ Presigned URL generated for {audio_format['file_name']}")
                    print(f"   📁 Path: {upload_response['file_path']}")
                else:
                    error_text = await response.text()
                    print(f"   ❌ Failed: {error_text}")


async def main():
    """Run audio upload examples."""
    print("=== Audio File Upload Examples ===\n")
    
    try:
        print("1. Single MP3 upload example:")
        await upload_audio_file()
        
        print("\n" + "="*50)
        print("2. Multiple audio format examples:")
        await upload_different_audio_formats()
        
    except aiohttp.ClientError as e:
        print(f"❌ Connection error: {e}")
        print("   Make sure the API server is running on http://localhost:8080")
    except Exception as e:
        print(f"❌ Unexpected error: {e}")


if __name__ == "__main__":
    print("Starting audio upload examples...")
    print("Make sure the API server is running: uv run python src/api/main.py")
    print("Press Ctrl+C to cancel\n")
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\n👋 Examples cancelled by user")
    except Exception as e:
        print(f"\n❌ Error: {e}")