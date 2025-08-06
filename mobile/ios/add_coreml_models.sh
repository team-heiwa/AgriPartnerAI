#!/bin/bash

# Script to add Core ML models to Xcode project
# Run this from the mobile/ios directory

echo "Adding Core ML models to Xcode project..."

# Create Models directory if it doesn't exist
mkdir -p Runner/Models

# Copy Core ML models to the project
echo "Copying Core ML models..."
cp -r ../coreml_models/GemmaEmbedding.mlpackage Runner/Models/
cp -r ../coreml_models/GemmaTextProcessor.mlpackage Runner/Models/
cp -r ../coreml_models/GemmaSmall_Embedding.mlpackage Runner/Models/
cp -r ../coreml_models/Gemma3nE4B_Embedding.mlpackage Runner/Models/

echo "✅ Core ML models copied to Runner/Models/"

# Instructions for Xcode
echo ""
echo "📋 Next steps in Xcode:"
echo "1. Open ios/Runner.xcworkspace"
echo "2. Right-click on 'Runner' in project navigator"
echo "3. Select 'Add Files to Runner...'"
echo "4. Navigate to Runner/Models/"
echo "5. Select all .mlpackage files"
echo "6. Make sure 'Copy items if needed' is checked"
echo "7. Add to target 'Runner'"
echo "8. Click 'Add'"
echo ""
echo "After adding models, clean and rebuild:"
echo "flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter run" 