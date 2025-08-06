# AgriPartner Mobile App

A Flutter-based iOS application for AgriPartnerAI, enabling field agents to record visits, manage drone operations, and access agricultural insights on the go.

## Features

- **Audio Recording**: Record field visit notes with built-in audio capture
- **Location Tracking**: GPS-enabled mapping for accurate field documentation
- **Drone Operations**: Control and monitor agricultural drones
- **Report Generation**: Access AI-generated insights and recommendations
- **Offline Support**: Continue working without internet connectivity
- **Secure Authentication**: JWT-based auth with biometric support

## Prerequisites

- Flutter 3.19.0 or higher
- Xcode 14.0 or higher
- iOS 12.0 or higher
- CocoaPods 1.12.0 or higher

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

## Deployment

### TestFlight

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

## License

Copyright © 2025 AgriPartnerAI. All rights reserved.