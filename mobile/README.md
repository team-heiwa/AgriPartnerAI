# AgriPartnerAI Mobile App

**Submission for Google Gemma 3n Impact Challenge**

A Flutter-based iOS application for AgriPartnerAI, enabling generational knowledge transfer in agriculture through on-device AI powered by Google's Gemma 3n model. This app bridges the expertise gap between veteran farmers and the next generation by preserving and sharing agricultural wisdom through an AI partner named "Kei".

## Features

- **On-Device AI with Gemma 3n**: Leverages MLX Swift for offline inference using Google's Gemma 3n E4B model
- **Knowledge Transfer System**: Captures and preserves farming expertise through observation cards
- **AI Agriculture Partner "Kei"**: Interactive AI assistant trained on veteran farmer knowledge
- **Multi-Modal Learning**: Combines text, voice, and visual inputs for comprehensive knowledge capture
- **Offline-First Architecture**: Full functionality without internet connectivity using on-device models
- **Privacy-Focused**: All inference happens on-device, ensuring farmer data privacy

## Prerequisites

- Flutter 3.19.0 or higher
- Xcode 14.0 or higher
- iOS 17.0 or higher (for MLX support)
- CocoaPods 1.12.0 or higher
- Device with 6GB+ RAM for on-device inference
- macOS 14.0+ for development

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/AgriPartnerAI.git
   cd AgriPartnerAI/mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **iOS setup**
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Configure environment**
   ```bash
   # For development
   flutter run --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=ENVIRONMENT=development
   
   # For production
   flutter run --dart-define=API_BASE_URL=https://api.agripartner.ai --dart-define=ENVIRONMENT=production
   ```

## Development

### Running the app

```bash
# Run on iOS simulator
flutter run

# Run on specific device
flutter run -d [device-id]

# Run with hot reload
flutter run --hot
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget/login_test.dart
```

### Building

```bash
# Build for iOS (debug)
flutter build ios --debug

# Build for iOS (release)
flutter build ios --release

# Build without code signing (CI/CD)
flutter build ios --release --no-codesign
```

## Project Structure

```
lib/
├── api/              # API clients and network layer
├── config/           # App configuration and constants
├── models/           # Data models
├── screens/          # UI screens organized by feature
├── services/         # Business logic and services
├── utils/            # Utility functions and helpers
└── widgets/          # Reusable UI components
```

## Architecture

- **State Management**: Provider pattern for simplicity and performance
- **Navigation**: GoRouter for declarative routing
- **Network**: Dio with interceptors for API communication
- **Storage**: SharedPreferences for local data persistence

## Key Components

### Authentication Flow
1. User enters credentials on login screen
2. AuthService validates with backend API
3. JWT token stored securely
4. Auto-refresh on 401 responses

### Audio Recording
1. Request microphone permissions
2. Record audio in M4A format
3. Upload to Google Cloud Storage
4. Process with AI pipeline

### Offline Capabilities
- Queue recordings for upload when online
- Cache essential data locally
- Sync automatically on connection

## Permissions

The app requires the following iOS permissions:

- **Camera**: Photo/video capture for field documentation
- **Microphone**: Audio recording for visit notes
- **Location**: GPS tracking for field mapping
- **Photo Library**: Save and access field images

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| API_BASE_URL | Backend API endpoint | https://api.agripartner.ai |
| ENVIRONMENT | App environment | development |

## Demo Deployment

### Web Version (For Hackathon Judges)

A web version is available for UI/UX demonstration purposes:

```bash
# Build web version
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

**Note**: The web version demonstrates the UI/UX flow but does not include on-device MLX inference capabilities, which are iOS-specific.

### TestFlight (Full iOS Experience)

1. Update version in `pubspec.yaml`
2. Build release version
3. Archive in Xcode
4. Upload to App Store Connect
5. Submit for TestFlight review

### App Store

1. Complete app metadata
2. Add screenshots for all device sizes
3. Submit for App Store review
4. Monitor review status

## Troubleshooting

### Common Issues

**Build fails with "Module not found"**
```bash
cd ios
pod deintegrate
pod install
```

**Simulator not showing up**
```bash
flutter doctor
open -a Simulator
```

**Permission denied errors**
- Check Info.plist for proper usage descriptions
- Reset simulator permissions in Settings

## Contributing

1. Create feature branch from `main`
2. Make changes following Flutter style guide
3. Add tests for new features
4. Submit PR with clear description

## On-Device Model Setup

### Installing Gemma 3n Model

1. **Download the model from Hugging Face**:
   ```bash
   # Install Hugging Face CLI
   pip install huggingface-hub
   
   # Download Gemma 3n E4B model
   huggingface-cli download google/gemma-3n-e4b-it-4bit \
     --local-dir ./models/gemma-3n-e4b
   ```

2. **Add MLX Swift Package to Xcode**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Add package dependency: `https://github.com/ml-explore/mlx-swift`
   - Add package dependency: `https://github.com/ml-explore/mlx-swift-examples`

3. **Place model files**:
   ```bash
   cp -r ./models/gemma-3n-e4b/* ios/Runner/Models/
   ```

## Model Attribution

This application uses Google's Gemma 3n model, specifically the E4B-it-4bit variant optimized for on-device inference. Gemma models are open-weight models released by Google under the Gemma Terms of Use.

- **Model**: Gemma 3n E4B-it-4bit
- **Source**: [Hugging Face](https://huggingface.co/google/gemma-3n-e4b-it-4bit)
- **License**: [Gemma Terms of Use](https://ai.google.dev/gemma/terms)
- **Framework**: MLX Swift for on-device inference

## Competition Context

This project is submitted to the **Google Gemma 3n Impact Challenge** on Kaggle, demonstrating innovative use of Gemma models for social impact in agriculture. The application addresses the critical challenge of preserving and transferring agricultural knowledge between generations, particularly important as the global farming population ages.

### Impact Goals
- Preserve traditional farming knowledge before it's lost
- Bridge the technology gap in agriculture
- Enable sustainable farming practices through AI-assisted learning
- Support rural communities with offline-capable technology

## License

### Application Code
Copyright © 2025 AgriPartnerAI. All rights reserved.

The application source code is proprietary. For licensing inquiries, please contact the development team.

### Model License
The Gemma 3n model is used under the [Gemma Terms of Use](https://ai.google.dev/gemma/terms). Users must comply with these terms when using the application.

### Third-Party Libraries
This project uses various open-source libraries. See `pubspec.yaml` and `Package.swift` for detailed dependency information and their respective licenses.

## Acknowledgments

- Google DeepMind for developing and releasing the Gemma model family
- Apple ML Explore team for the MLX framework
- The Flutter and Swift communities for their excellent tools and libraries
- Kaggle for hosting the Google Gemma 3n Impact Challenge