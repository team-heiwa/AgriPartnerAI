# AgriPartner AI Backend

This backend service provides a pipeline for processing audio and image files from Google Cloud Storage (GCS) using Large Language Models (LLMs) via Google Vertex AI.

## Overview

The pipeline follows this flow:
1. Retrieve media files (audio/images) from GCS
2. Pre-process media files for LLM consumption
3. Send to Vertex AI (Gemini) for analysis
4. Store processed results back to GCS

## Project Structure

```
backend/
├── src/
│   ├── gcs/              # Google Cloud Storage operations
│   ├── processors/       # Media preprocessing (audio/image)
│   ├── llm/             # Vertex AI / LLM integration
│   ├── pipeline/        # Main pipeline orchestration
│   └── utils/           # Shared utilities and logging
├── examples/            # Example usage scripts
├── tests/              # Unit and integration tests
├── docker/             # Docker configuration
├── pyproject.toml      # Package dependencies (managed by uv)
├── ruff.toml          # Python linting configuration
└── .env.example       # Environment variables template
```

## Prerequisites

- Python 3.11+
- Google Cloud Project with billing enabled
- Service Account with appropriate permissions
- ffmpeg (for audio processing with pydub)

## Setup

1. **Clone and navigate to backend**
   ```bash
   cd AgriPartnerAI/backend
   ```

2. **Install dependencies using uv**
   ```bash
   uv sync
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Configure Google Cloud credentials**
   ```bash
   # Option 1: Service account key file
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
   
   # Option 2: Use gcloud auth (for development)
   gcloud auth application-default login
   ```

5. **Create GCP resources (if not already done)**
   ```bash
   cd ../infra/terraform
   terraform init
   terraform apply
   ```

## Configuration

Key environment variables:

- `GCP_PROJECT_ID`: Your Google Cloud project ID
- `GCS_INPUT_BUCKET`: Bucket for input media files
- `GCS_OUTPUT_BUCKET`: Bucket for processed results
- `VERTEX_AI_MODEL`: LLM model to use (default: gemini-1.5-flash)
- `MAX_IMAGE_SIZE_MB`: Maximum image size in MB
- `MAX_AUDIO_DURATION_SECONDS`: Maximum audio duration in seconds

## Usage

### Basic Example

```python
from src.pipeline import Pipeline

# Initialize pipeline
pipeline = Pipeline()

# Process an image
result = await pipeline.process_image(
    bucket="my-input-bucket",
    file_path="images/photo.jpg",
    prompt="Describe what you see in this image"
)

# Process audio
result = await pipeline.process_audio(
    bucket="my-input-bucket", 
    file_path="audio/recording.mp3",
    prompt="Transcribe this audio"
)
```

### Running Examples

```bash
# Run image processing example
uv run python examples/process_image.py

# Run audio processing example
uv run python examples/process_audio.py
```

## Development

### Code Quality

```bash
# Run linting
uv run ruff check .

# Format code
uv run ruff format .

# Run tests
uv run pytest
```

### Project Commands

```bash
# Install dev dependencies
uv sync --dev

# Add new dependency
uv add package-name

# Update dependencies
uv lock --upgrade
```

## Docker Support

Build and run with Docker:

```bash
# Build image
docker build -t agripartner-backend .

# Run container
docker run --env-file .env agripartner-backend
```

## API Reference

### Pipeline Class

Main orchestrator for processing media files.

```python
class Pipeline:
    async def process_image(bucket: str, file_path: str, prompt: str) -> dict
    async def process_audio(bucket: str, file_path: str, prompt: str) -> dict
    async def process_batch(items: List[MediaItem]) -> List[dict]
```

### GCS Client

Handles Google Cloud Storage operations.

```python
class GCSClient:
    async def download_file(bucket: str, file_path: str) -> bytes
    async def upload_file(bucket: str, file_path: str, content: bytes) -> str
    async def list_files(bucket: str, prefix: str) -> List[str]
```

### Processors

Media preprocessing utilities.

```python
class ImageProcessor:
    async def process(image_bytes: bytes) -> ProcessedImage
    
class AudioProcessor:
    async def process(audio_bytes: bytes) -> ProcessedAudio
```

## Troubleshooting

### Common Issues

1. **Import errors**: Ensure you're using `uv run` to execute scripts
2. **ffmpeg not found**: Install ffmpeg for audio processing
3. **Authentication errors**: Check GOOGLE_APPLICATION_CREDENTIALS path
4. **Bucket access denied**: Verify service account permissions

### Logging

Enable detailed logging:
```bash
export LOG_LEVEL=DEBUG
```

## License

[Your License Here]