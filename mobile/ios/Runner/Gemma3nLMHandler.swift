import Foundation
import CoreML
import Accelerate

@available(iOS 16.0, *)
class Gemma3nLMHandler {
    private var lmModel: MLModel?
    private let tokenizer = GemmaTokenizer()
    private let vocabSize = 32000
    private let maxSeqLen = 128  // モデルの期待する長さに合わせる
    
    // Token IDs from tokenizer
    private var padToken: Int { GemmaTokenizer.padToken }
    private var bosToken: Int { GemmaTokenizer.bosToken }
    private var eosToken: Int { GemmaTokenizer.eosToken }
    
    init() {}
    
    func loadModel(at path: String) throws {
        let config = MLModelConfiguration()
        config.computeUnits = .all
        config.allowLowPrecisionAccumulationOnGPU = true
        
        let modelURL = URL(fileURLWithPath: path)
        
        // Check if it's already compiled (.mlmodelc) or needs compilation (.mlpackage)
        if path.hasSuffix(".mlpackage") {
            print("📦 Compiling mlpackage: \(path)")
            let compiledUrl = try MLModel.compileModel(at: modelURL)
            lmModel = try MLModel(contentsOf: compiledUrl, configuration: config)
        } else {
            print("📦 Loading compiled model: \(path)")
            lmModel = try MLModel(contentsOf: modelURL, configuration: config)
        }
        
        print("✅ Gemma3n LM model loaded successfully")
    }
    
    func generate(prompt: String, maxNewTokens: Int = 50) async throws -> String {
        print("🤖 Gemma3nLMHandler.generate called with prompt: \(prompt)")
        
        guard let model = lmModel else {
            print("❌ Model not loaded")
            throw NSError(domain: "Gemma3nLM", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        
        print("✅ Model is loaded, running actual inference...")
        
        // Create input tokens using proper tokenizer
        let inputTokens = tokenizer.encode(prompt)
        print("📝 Tokenized prompt '\(prompt)' into \(inputTokens.count) tokens: \(inputTokens)")
        
        // Generated tokens storage
        var generatedTokens: [Int] = []
        var currentInputLength = inputTokens.count
        
        // Generate tokens iteratively
        let maxSteps = min(maxNewTokens, 50) // Limit to prevent infinite loops
        for step in 0..<maxSteps {
            // Create input array for current context
            let inputArray = try MLMultiArray(shape: [1, maxSeqLen as NSNumber], dataType: .int32)
            
            // Fill with current tokens (including previously generated ones)
            let allTokens = inputTokens + generatedTokens
            let startIdx = max(0, allTokens.count - maxSeqLen) // Keep last maxSeqLen tokens if exceeding
            
            for i in 0..<maxSeqLen {
                let tokenIdx = startIdx + i
                if tokenIdx < allTokens.count {
                    inputArray[i] = NSNumber(value: allTokens[tokenIdx])
                } else {
                    inputArray[i] = NSNumber(value: padToken)
                }
            }
            
            // Create input and run inference
            let input = Gemma3nLMInput(input_ids: inputArray)
            let output = try model.prediction(from: input)
            
            // Debug: Print available features on first step
            if step == 0 {
                print("📊 Available output features:")
                for featureName in output.featureNames {
                    if let feature = output.featureValue(for: featureName) {
                        print("  - \(featureName): ", terminator: "")
                        if let array = feature.multiArrayValue {
                            print("shape=\(array.shape), type=\(array.dataType)")
                        } else {
                            print("type=\(feature.type)")
                        }
                    }
                }
            }
            
            // Try different possible output names
            var foundLogits = false
            let possibleNames = ["output", "logits", "predictions", "var_130", "Identity"]
            
            for outputName in possibleNames {
                if let logitsFeature = output.featureValue(for: outputName),
                   let logits = logitsFeature.multiArrayValue {
                    
                    print("✅ Found logits as '\(outputName)' with shape: \(logits.shape)")
                    
                    // Get the next token from the last non-padding position
                    let effectiveLength = min(allTokens.count, maxSeqLen)
                    let nextTokenPosition = effectiveLength - 1
                    
                    // Use temperature sampling to avoid repetition
                    let nextToken = sampleWithTemperature(logits: logits, position: nextTokenPosition, temperature: 0.8)
                    
                    print("Step \(step): Generated token \(nextToken) at position \(nextTokenPosition)")
                    
                    // Check for end of sequence
                    if nextToken == eosToken || nextToken == padToken {
                        print("🛑 Hit EOS/PAD token, stopping generation")
                        foundLogits = true
                        break
                    }
                    
                    generatedTokens.append(nextToken)
                    foundLogits = true
                    break
                }
            }
            
            if !foundLogits {
                print("❌ Could not find logits in output. Available features: \(output.featureNames)")
                break
            }
        }
        
        print("🔢 Generated \(generatedTokens.count) tokens: \(generatedTokens.prefix(10))...")
        
        // Convert tokens to text using tokenizer
        let processedTokens = tokenizer.processTokensForGeneration(generatedTokens)
        let generatedText = tokenizer.decode(processedTokens)
        
        print("🎯 Generated text: '\(generatedText)'")
        print("📊 Token statistics: input=\(inputTokens.count), generated=\(generatedTokens.count), unique=\(Set(generatedTokens).count)")
        
        // Return only the generated text, no fallbacks
        return generatedText
    }
    
    // Removed - no longer using mock responses
    
    private func tokenizeSimple(_ text: String) -> [Int] {
        // Very simple character-level tokenization for demo
        // In production, use proper tokenizer
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var tokens: [Int] = []
        
        for word in words {
            // Simple hash-based token assignment
            let hash = abs(word.hashValue) % (vocabSize - 100) + 100
            tokens.append(hash)
        }
        
        return tokens
    }
    
    private func argmax(logits: MLMultiArray, position: Int) -> Int {
        // Get the dimension info
        let dims = logits.shape.count
        
        if dims == 3 {
            // Shape is [batch, sequence, vocab]
            let vocabSize = Int(logits.shape[2].intValue)
            var maxLogit: Float = -Float.infinity
            var maxToken = 0
            
            for token in 0..<vocabSize {
                let index = [0, position, token] as [NSNumber]
                if let value = logits[index] as? Float {
                    if value > maxLogit {
                        maxLogit = value
                        maxToken = token
                    }
                }
            }
            return maxToken
        } else if dims == 2 {
            // Shape is [sequence, vocab]
            let vocabSize = Int(logits.shape[1].intValue)
            var maxLogit: Float = -Float.infinity
            var maxToken = 0
            
            for token in 0..<vocabSize {
                let index = [position, token] as [NSNumber]
                if let value = logits[index] as? Float {
                    if value > maxLogit {
                        maxLogit = value
                        maxToken = token
                    }
                }
            }
            return maxToken
        }
        
        return 0
    }
    
    private func greedySample(logits: MLMultiArray, seqPosition: Int) -> Int {
        return argmax(logits: logits, position: seqPosition)
    }
    
    private func sampleWithTemperature(logits: MLMultiArray, position: Int, temperature: Float = 1.0) -> Int {
        let dims = logits.shape.count
        let vocabSize = dims == 3 ? Int(logits.shape[2].intValue) : Int(logits.shape[1].intValue)
        
        // Extract logits for the position
        var logitValues: [Float] = []
        for token in 0..<vocabSize {
            let index = dims == 3 ? [0, position, token] as [NSNumber] : [position, token] as [NSNumber]
            if let value = logits[index] as? Float {
                logitValues.append(value / temperature)
            } else {
                logitValues.append(-Float.infinity)
            }
        }
        
        // Apply softmax
        let maxLogit = logitValues.max() ?? 0
        let expValues = logitValues.map { exp($0 - maxLogit) }
        let sumExp = expValues.reduce(0, +)
        let probabilities = expValues.map { $0 / sumExp }
        
        // Sample from the distribution
        let random = Float.random(in: 0..<1)
        var cumulativeProb: Float = 0
        
        for (idx, prob) in probabilities.enumerated() {
            cumulativeProb += prob
            if random < cumulativeProb {
                return idx
            }
        }
        
        return vocabSize - 1
    }
    
    // Removed - no longer needed
    
    // Removed - no longer needed
    
    // Removed - no longer using fallback responses
}

// Model input/output wrappers
@available(iOS 16.0, *)
class Gemma3nLMInput: MLFeatureProvider {
    let input_ids: MLMultiArray
    
    var featureNames: Set<String> {
        return ["input_ids"]
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "input_ids" {
            return MLFeatureValue(multiArray: input_ids)
        }
        return nil
    }
    
    init(input_ids: MLMultiArray) {
        self.input_ids = input_ids
    }
}
