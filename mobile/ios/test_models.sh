#!/bin/bash

# Test script to verify Core ML models are accessible
echo "Testing Core ML model accessibility..."

# Check if models exist in the copied location
echo "📁 Checking models in Runner/Models/:"
ls -la Runner/Models/

# Check if models can be found by name
echo ""
echo "🔍 Testing model path resolution:"
for model in GemmaEmbedding GemmaTextProcessor GemmaSmall_Embedding Gemma3nE4B_Embedding; do
    echo "Testing $model..."
    if [ -d "Runner/Models/${model}.mlpackage" ]; then
        echo "✅ $model.mlpackage found"
    else
        echo "❌ $model.mlpackage not found"
    fi
done

echo ""
echo "📋 Next steps:"
echo "1. Open Xcode: open Runner.xcworkspace"
echo "2. Add the .mlpackage files to the project"
echo "3. Clean and rebuild: flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter run" 