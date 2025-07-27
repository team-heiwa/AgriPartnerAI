#!/usr/bin/env python3
"""Test script to verify the setup."""

import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
    print(" python-dotenv imported successfully")
except ImportError as e:
    print(f" Failed to import python-dotenv: {e}")

try:
    from google.cloud import storage
    print(" google-cloud-storage imported successfully")
except ImportError as e:
    print(f" Failed to import google-cloud-storage: {e}")

try:
    from google.cloud import aiplatform
    print(" google-cloud-aiplatform imported successfully")
except ImportError as e:
    print(f" Failed to import google-cloud-aiplatform: {e}")

try:
    from PIL import Image
    print(" Pillow (PIL) imported successfully")
except ImportError as e:
    print(f" Failed to import Pillow: {e}")

try:
    from pydub import AudioSegment
    print(" pydub imported successfully")
except ImportError as e:
    print(f" Failed to import pydub: {e}")

try:
    from pydantic import BaseModel
    print(" pydantic imported successfully")
except ImportError as e:
    print(f" Failed to import pydantic: {e}")

print(f"\nPython version: {sys.version}")
print(f"Script location: {Path(__file__).absolute()}")

# Load environment variables
env_path = Path(__file__).parent.parent / ".env"
if env_path.exists():
    load_dotenv(env_path)
    print(f"\n Loaded .env from {env_path}")
else:
    print(f"\n No .env file found at {env_path}")
    print("  Create one from .env.example to configure your credentials")

print("\nSetup verification complete!")