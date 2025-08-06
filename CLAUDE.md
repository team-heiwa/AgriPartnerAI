# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

AgriPartnerAI is a multi-platform agricultural knowledge transfer system designed to bridge generational farming expertise. The project consists of:
- **Frontend**: Next.js web dashboard for farm management
- **Backend**: FastAPI service for processing agricultural media via Google Vertex AI
- **Mobile**: Flutter iOS app for field agents with AI integration
- **Infrastructure**: Terraform-managed Google Cloud Platform resources

## Essential Commands

### Mobile Development (Primary Focus)


```bash
cd mobile
flutter pub get                    # Install dependencies
flutter run                        # Run on connected device/simulator
flutter test                       # Run all tests
flutter test test/widget_test.dart # Run specific test
flutter build ios                  # Build for iOS
flutter run --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=ENVIRONMENT=development
```

### Backend Development
```bash
cd backend
uv sync                           # Install dependencies with uv package manager
uv run python -m src.api.main     # Run FastAPI server
uv run ruff check .               # Lint code
uv run ruff format .              # Format code
uv run pytest                     # Run tests
uv add <package>                  # Add new dependency
```

### Frontend Development
```bash
cd frontend
pnpm install                      # Install dependencies
pnpm dev                          # Development server
pnpm build                        # Production build
pnpm lint                         # Run linter
```

### Infrastructure
```bash
cd infra/terraform
terraform init
terraform plan
terraform apply
```

## Architecture and Key Patterns

### Mobile App Architecture
The mobile app (`/mobile/`) implements a knowledge transfer flow where users:
1. Learn from veteran farmers through observation cards
2. Build a knowledge library
3. Consult with AI Partner "Kei" who learned from veteran knowledge

**Key architectural decisions:**
- **State Management**: Provider pattern for simplicity
- **Navigation**: GoRouter with named routes (e.g., `/home`, `/library`, `/ai-advisor`)
- **AI Integration**: Multiple service abstractions in `/lib/services/ai/`:
  - `CoreMLService`: On-device AI using Apple's CoreML
  - `MediaPipeService`: Cross-platform ML inference
  - `HTTPAIService`: Remote AI via HTTP
  - Service selection based on user's chosen model tier

**Important screens flow:**
1. **HomeScreen** (`/home`): Entry point with "Begin the Legacy with Kei" CTA
2. **ObservationCardSelectionScreen**: Generates and saves observation cards
3. **LibraryScreen** (`/library`): Manages knowledge cards with veteran/myfarm filtering
4. **AIAdvisorScreen** (`/ai-advisor`): Chat with AI Partner Kei, can add/remove observation cards

### Backend Pipeline Architecture
The backend (`/backend/`) processes agricultural media through a pipeline:
1. Retrieve from Google Cloud Storage
2. Preprocess media (audio/image)
3. Send to Vertex AI (Gemini models)
4. Store results back to GCS

**Key components:**
- `/src/pipeline/`: Main orchestration logic
- `/src/processors/`: Media preprocessing
- `/src/llm/`: Vertex AI integration
- `/src/gcs/`: Cloud Storage operations

### Frontend Dashboard
The frontend (`/frontend/`) provides a web dashboard with:
- Japanese localization (`lang="ja"`)
- Standalone build for Cloud Run deployment
- Tailwind CSS for styling

## Critical Implementation Details

### Mobile App Specifics
- **Observation Cards**: Core data structure for knowledge transfer
  ```dart
  class ObservationCardCandidate {
    String id, title, description;
    String? outcome;
    String context; // 'veteran' or 'myfarm'
    DateTime timestamp;
    List<String> tags, rawInputs;
  }
  ```
- **Chat UI Toggle**: Users can fold/unfold chat to see bigger camera view
- **Navigation**: Use `context.push()` not `context.go()` to maintain back stack
- **State Management**: Use `setState()` after `Navigator.pop()` for modal updates

### Backend Processing
- Uses `uv` package manager (modern Python tooling)
- Async/await patterns throughout
- Google Cloud authentication via service account or ADC
- Media size limits configured via environment variables

### Deployment Configuration
- **GitHub Actions**: Workflows for all components in `.github/workflows/`
- **Cloud Run**: Auto-scaling 0-5 instances for backend/frontend
- **Region**: Asia Northeast 1 (Tokyo) primary deployment
- **Authentication**: Workload Identity Federation for CI/CD

## Common Development Tasks

### Adding New Observation Cards
1. Update `ObservationCardCandidate` model if needed
2. Modify generation logic in `ObservationCardSelectionScreen`
3. Update filtering in `LibraryScreen` if new categories added

### Modifying AI Chat Interface
1. Edit `AIAdvisorScreen` for UI changes
2. Update `_currentObservationCards` for card management
3. Ensure `_isChatFolded` state properly hides/shows UI elements

### Testing Mobile Features
```bash
# Widget tests
flutter test test/widget_test.dart

# Integration tests (if available)
flutter test integration_test/

# Run on specific iOS version
flutter run --device-id [device-id]
```

## Environment Configuration

### Mobile App
- `API_BASE_URL`: Backend API endpoint
- `ENVIRONMENT`: development/staging/production
- Configured via `--dart-define` flags or compile-time constants

### Backend
- `GCP_PROJECT_ID`: Google Cloud project
- `GCS_INPUT_BUCKET`: Input media bucket
- `GCS_OUTPUT_BUCKET`: Processed results bucket
- `VERTEX_AI_MODEL`: LLM model (default: gemini-1.5-flash)

## Current Development Context
- Active branch: `add-mobile`
- Recent focus: Mobile app UI/UX improvements
- Key changes: Simplified navigation, "Kei" branding, observation card management