import Foundation
import CoreML
import Flutter

@available(iOS 15.0, *)
class GemmaMLHandler: NSObject {
    private var model: MLModel?
    private let modelName = "Gemma2B_4bit"
    
    // Token configuration
    private let vocabSize = 256000
    private let bosToken = 1
    private let eosToken = 2
    private let padToken = 0
    
    override init() {
        super.init()
    }
    
    func getModelPath(modelName: String) -> String? {
        // Check for compiled model in app bundle
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") {
            return modelURL.path
        }
        
        // Check for model in documents directory
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let modelPath = "\(documentsPath)/\(modelName).mlmodelc"
        
        if FileManager.default.fileExists(atPath: modelPath) {
            return modelPath
        }
        
        return nil
    }
    
    func initializeModel(modelPath: String, computeUnits: String) -> Bool {
        do {
            let config = MLModelConfiguration()
            
            // Configure compute units
            switch computeUnits {
            case "cpuOnly":
                config.computeUnits = .cpuOnly
            case "cpuAndGPU":
                config.computeUnits = .cpuAndGPU
            case "all":
                config.computeUnits = .all
            default:
                config.computeUnits = .all
            }
            
            // Set memory constraints
            config.allowLowPrecisionAccumulationOnGPU = true
            
            let modelURL = URL(fileURLWithPath: modelPath)
            model = try MLModel(contentsOf: modelURL, configuration: config)
            
            return true
        } catch {
            print("Failed to load model: \(error)")
            return false
        }
    }
    
    func generateText(prompt: String, systemPrompt: String, maxTokens: Int, temperature: Double, topP: Double) throws -> String {
        guard let model = model else {
            throw GemmaError.modelNotInitialized
        }
        
        // Tokenize input
        let fullPrompt = "\(systemPrompt)\n\nUser: \(prompt)\n\nAssistant:"
        let inputTokens = tokenize(text: fullPrompt)
        
        // Prepare input
        let inputArray = try MLMultiArray(shape: [1, NSNumber(value: inputTokens.count)], dataType: .int32)
        for (index, token) in inputTokens.enumerated() {
            inputArray[index] = NSNumber(value: token)
        }
        
        // Generate tokens
        var outputTokens: [Int32] = []
        var currentInput = inputArray
        
        for _ in 0..<maxTokens {
            // Run inference
            let input = GemmaInput(input_ids: currentInput)
            let output = try model.prediction(from: input)
            
            // Get logits and sample next token
            guard let logits = output.featureValue(for: "logits")?.multiArrayValue else {
                throw GemmaError.invalidOutput
            }
            
            let nextToken = sampleToken(from: logits, temperature: temperature, topP: topP)
            outputTokens.append(nextToken)
            
            // Stop if EOS token
            if nextToken == Int32(eosToken) {
                break
            }
            
            // Update input for next iteration
            currentInput = try appendToken(to: currentInput, token: nextToken)
        }
        
        // Decode output
        return detokenize(tokens: outputTokens)
    }
    
    func analyzeImage(imagePath: String, context: String) throws -> String {
        // For E2B model without built-in vision, we'd need to:
        // 1. Extract image features using Vision framework
        // 2. Convert features to text description
        // 3. Pass to language model
        
        // Placeholder for now - would integrate with Vision framework
        return "Image analysis requires vision-enabled model (E4B) or separate feature extraction."
    }
    
    // MARK: - Tokenization helpers
    
    private func tokenize(text: String) -> [Int32] {
        // Simplified tokenization - in production, use proper tokenizer
        var tokens: [Int32] = [Int32(bosToken)]
        
        // Basic word-level tokenization (placeholder)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        for word in words where !word.isEmpty {
            // Hash word to token ID (simplified)
            let hash = word.hashValue
            let tokenId = abs(hash) % (vocabSize - 100) + 100 // Avoid special tokens
            tokens.append(Int32(tokenId))
        }
        
        return tokens
    }
    
    private func detokenize(tokens: [Int32]) -> String {
        // Placeholder detokenization
        return tokens.map { "token_\($0)" }.joined(separator: " ")
    }
    
    private func sampleToken(from logits: MLMultiArray, temperature: Double, topP: Double) -> Int32 {
        // Apply temperature
        let vocabSize = logits.shape[logits.shape.count - 1].intValue
        var probabilities = [Double](repeating: 0, count: vocabSize)
        
        var maxLogit = -Double.infinity
        for i in 0..<vocabSize {
            let logit = logits[[0, 0, i] as [NSNumber]].doubleValue
            if logit > maxLogit { maxLogit = logit }
        }
        
        var sum = 0.0
        for i in 0..<vocabSize {
            let logit = logits[[0, 0, i] as [NSNumber]].doubleValue
            probabilities[i] = exp((logit - maxLogit) / temperature)
            sum += probabilities[i]
        }
        
        // Normalize
        for i in 0..<vocabSize {
            probabilities[i] /= sum
        }
        
        // Top-p sampling
        let sortedIndices = (0..<vocabSize).sorted { probabilities[$0] > probabilities[$1] }
        var cumulativeProb = 0.0
        var cutoff = vocabSize
        
        for (index, tokenId) in sortedIndices.enumerated() {
            cumulativeProb += probabilities[tokenId]
            if cumulativeProb > topP {
                cutoff = index + 1
                break
            }
        }
        
        // Sample from top-p tokens
        let topTokens = Array(sortedIndices.prefix(cutoff))
        let randomValue = Double.random(in: 0..<1)
        var cumulative = 0.0
        
        for tokenId in topTokens {
            cumulative += probabilities[tokenId]
            if cumulative > randomValue {
                return Int32(tokenId)
            }
        }
        
        return Int32(topTokens.last ?? 0)
    }
    
    private func appendToken(to input: MLMultiArray, token: Int32) throws -> MLMultiArray {
        let oldLength = input.shape[1].intValue
        let newInput = try MLMultiArray(shape: [1, NSNumber(value: oldLength + 1)], dataType: .int32)
        
        // Copy existing tokens
        for i in 0..<oldLength {
            newInput[i] = input[i]
        }
        
        // Add new token
        newInput[oldLength] = NSNumber(value: token)
        
        return newInput
    }
    
    func clearCache() {
        // Clear any cached data
        model = nil
    }
    
    func dispose() {
        model = nil
    }
}

// MARK: - Input/Output types

@available(iOS 15.0, *)
class GemmaInput: MLFeatureProvider {
    let input_ids: MLMultiArray
    
    var featureNames: Set<String> {
        return ["input_ids"]
    }
    
    init(input_ids: MLMultiArray) {
        self.input_ids = input_ids
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        switch featureName {
        case "input_ids":
            return MLFeatureValue(multiArray: input_ids)
        default:
            return nil
        }
    }
}

// MARK: - Error types

enum GemmaError: Error {
    case modelNotInitialized
    case invalidOutput
    case tokenizationError
}

// MARK: - Flutter Channel Handler

@available(iOS 15.0, *)
class GemmaChannelHandler: NSObject, FlutterPlugin {
    private let handler = GemmaMLHandler()
    
    static func register(with registrar: FlutterPluginRegistrar) {
        print("🚀 GemmaChannelHandler.register called")
        let channel = FlutterMethodChannel(name: "agripartner.ai/gemma", binaryMessenger: registrar.messenger())
        let instance = GemmaChannelHandler()
        registrar.addMethodCallDelegate(instance, channel: channel)
        print("✅ GemmaChannelHandler registered successfully")
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getModelPath":
            guard let args = call.arguments as? [String: Any],
                  let modelName = args["modelName"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing modelName", details: nil))
                return
            }
            
            let path = handler.getModelPath(modelName: modelName) ?? ""
            result(path)
            
        case "initializeModel":
            guard let args = call.arguments as? [String: Any],
                  let modelPath = args["modelPath"] as? String,
                  let computeUnits = args["computeUnits"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                return
            }
            
            let success = handler.initializeModel(modelPath: modelPath, computeUnits: computeUnits)
            result(success)
            
        case "generateText":
            guard let args = call.arguments as? [String: Any],
                  let prompt = args["prompt"] as? String,
                  let systemPrompt = args["systemPrompt"] as? String,
                  let maxTokens = args["maxTokens"] as? Int,
                  let temperature = args["temperature"] as? Double,
                  let topP = args["topP"] as? Double else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                return
            }
            
            do {
                let text = try handler.generateText(
                    prompt: prompt,
                    systemPrompt: systemPrompt,
                    maxTokens: maxTokens,
                    temperature: temperature,
                    topP: topP
                )
                result(text)
            } catch {
                result(FlutterError(code: "GENERATION_ERROR", message: error.localizedDescription, details: nil))
            }
            
        case "analyzeImage":
            guard let args = call.arguments as? [String: Any],
                  let imagePath = args["imagePath"] as? String,
                  let context = args["context"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                return
            }
            
            do {
                let analysis = try handler.analyzeImage(imagePath: imagePath, context: context)
                result(analysis)
            } catch {
                result(FlutterError(code: "ANALYSIS_ERROR", message: error.localizedDescription, details: nil))
            }
            
        case "clearCache":
            handler.clearCache()
            result(nil)
            
        case "dispose":
            handler.dispose()
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
