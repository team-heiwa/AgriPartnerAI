import Foundation
import CoreML
import Flutter

@available(iOS 16.0, *)
class GemmaCoreMLHandler: NSObject {
    private var embeddingModel: MLModel?
    private var textProcessor: MLModel?
    
    // Model configuration
    private let maxSequenceLength = 128
    private let hiddenSize = 768
    private let vocabSize = 50000
    
    // Model names
    private let embeddingModelName = "GemmaEmbedding"
    private let textProcessorName = "GemmaTextProcessor"
    
    // Performance monitoring
    private var lastInferenceTime: Double = 0
    
    override init() {
        super.init()
    }
    
    // MARK: - Model Management
    
    func getModelPath(modelName: String) -> String? {
        // Check for compiled model in app bundle
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") {
            return modelURL.path
        }
        
        // Check for model in documents directory (downloaded models)
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let modelPath = "\(documentsPath)/models/\(modelName).mlpackage"
        
        if FileManager.default.fileExists(atPath: modelPath) {
            return modelPath
        }
        
        return nil
    }
    
    func initializeModels(embeddingPath: String?, textProcessorPath: String?, computeUnits: String) -> Bool {
        let config = MLModelConfiguration()
        
        // Configure compute units for Neural Engine optimization
        switch computeUnits {
        case "cpuOnly":
            config.computeUnits = .cpuOnly
        case "cpuAndGPU":
            config.computeUnits = .cpuAndGPU
        case "neuralEngine":
            config.computeUnits = .cpuAndNeuralEngine
        case "all":
            config.computeUnits = .all  // Neural Engine + GPU + CPU
        default:
            config.computeUnits = .all
        }
        
        // Enable performance optimizations
        if #available(iOS 16.0, *) {
            config.allowLowPrecisionAccumulationOnGPU = true
        }
        
        // Load embedding model
        if let path = embeddingPath ?? getModelPath(modelName: embeddingModelName) {
            do {
                let modelURL = URL(fileURLWithPath: path)
                embeddingModel = try MLModel(contentsOf: modelURL, configuration: config)
                print("✅ Embedding model loaded from: \(path)")
            } catch {
                print("❌ Failed to load embedding model: \(error)")
                return false
            }
        }
        
        // Load text processor model
        if let path = textProcessorPath ?? getModelPath(modelName: textProcessorName) {
            do {
                let modelURL = URL(fileURLWithPath: path)
                textProcessor = try MLModel(contentsOf: modelURL, configuration: config)
                print("✅ Text processor loaded from: \(path)")
            } catch {
                print("❌ Failed to load text processor: \(error)")
                return false
            }
        }
        
        // Warm up models with dummy input
        warmUpModels()
        
        return embeddingModel != nil || textProcessor != nil
    }
    
    private func warmUpModels() {
        let dummyTokens = Array(repeating: Int32(1), count: 10)
        _ = processTokens(dummyTokens)
        print("✅ Models warmed up")
    }
    
    // MARK: - Inference
    
    func processTokens(_ tokenIds: [Int32]) -> MLMultiArray? {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        guard let embeddingModel = embeddingModel else {
            print("❌ Embedding model not loaded")
            return nil
        }
        
        // Step 1: Create input array for embeddings
        guard let inputArray = try? MLMultiArray(
            shape: [1, NSNumber(value: maxSequenceLength)],
            dataType: .int32
        ) else {
            print("❌ Failed to create input array")
            return nil
        }
        
        // Fill with token IDs (pad with zeros)
        for i in 0..<maxSequenceLength {
            if i < tokenIds.count {
                inputArray[i] = NSNumber(value: tokenIds[i])
            } else {
                inputArray[i] = NSNumber(value: 0)  // Padding
            }
        }
        
        // Step 2: Get embeddings
        let embeddingInput = try? MLDictionaryFeatureProvider(
            dictionary: ["input_ids": MLFeatureValue(multiArray: inputArray)]
        )
        
        guard let embeddingInput = embeddingInput,
              let embeddingOutput = try? embeddingModel.prediction(from: embeddingInput),
              let embeddings = embeddingOutput.featureValue(for: "embeddings")?.multiArrayValue else {
            print("❌ Embedding inference failed")
            return nil
        }
        
        // Step 3: Process through text model (if available)
        if let textProcessor = textProcessor {
            let processorInput = try? MLDictionaryFeatureProvider(
                dictionary: ["embeddings": MLFeatureValue(multiArray: embeddings)]
            )
            
            if let processorInput = processorInput,
               let processorOutput = try? textProcessor.prediction(from: processorInput),
               let output = processorOutput.featureValue(for: "output")?.multiArrayValue {
                lastInferenceTime = CFAbsoluteTimeGetCurrent() - startTime
                return output
            }
        }
        
        lastInferenceTime = CFAbsoluteTimeGetCurrent() - startTime
        return embeddings
    }
    
    // MARK: - Batch Processing
    
    func processBatch(_ tokenBatches: [[Int32]], completion: @escaping ([MLMultiArray?]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let results = tokenBatches.map { tokens in
                self?.processTokens(tokens)
            }
            
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    // MARK: - Text Generation (Simplified)
    
    func generateEmbeddings(for text: String) -> MLMultiArray? {
        // Convert text to token IDs (simplified - use actual tokenizer in production)
        let tokens = tokenizeText(text)
        return processTokens(tokens)
    }
    
    private func tokenizeText(_ text: String) -> [Int32] {
        // Simplified tokenization - in production, use proper tokenizer
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        var tokens: [Int32] = []
        
        for word in words where !word.isEmpty {
            // Simple hash-based tokenization
            let hash = word.hashValue
            let tokenId = abs(hash) % (vocabSize - 100) + 100
            tokens.append(Int32(tokenId))
        }
        
        return Array(tokens.prefix(maxSequenceLength))
    }
    
    // MARK: - Performance Metrics
    
    func getPerformanceMetrics() -> [String: Any] {
        let tokensPerSecond = lastInferenceTime > 0 ? Double(maxSequenceLength) / lastInferenceTime : 0
        
        return [
            "lastInferenceTime": lastInferenceTime,
            "tokensPerSecond": tokensPerSecond,
            "maxSequenceLength": maxSequenceLength,
            "modelLoaded": embeddingModel != nil
        ]
    }
    
    // MARK: - Memory Management
    
    func clearCache() {
        // Clear any cached data
    }
    
    func dispose() {
        embeddingModel = nil
        textProcessor = nil
    }
}

// MARK: - Flutter Plugin

@available(iOS 16.0, *)
class GemmaCoreMLPlugin: NSObject, FlutterPlugin {
    private let handler = GemmaCoreMLHandler()
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "agripartner.ai/gemma_coreml",
            binaryMessenger: registrar.messenger()
        )
        let instance = GemmaCoreMLPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeModels":
            guard let args = call.arguments as? [String: Any] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                return
            }
            
            let embeddingPath = args["embeddingPath"] as? String
            let textProcessorPath = args["textProcessorPath"] as? String
            let computeUnits = args["computeUnits"] as? String ?? "all"
            
            let success = handler.initializeModels(
                embeddingPath: embeddingPath,
                textProcessorPath: textProcessorPath,
                computeUnits: computeUnits
            )
            result(success)
            
        case "processTokens":
            guard let args = call.arguments as? [String: Any],
                  let tokenIds = args["tokenIds"] as? [Int] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing tokenIds", details: nil))
                return
            }
            
            let tokens = tokenIds.map { Int32($0) }
            if let output = handler.processTokens(tokens) {
                // Convert MLMultiArray to array for Flutter
                var outputArray: [Double] = []
                for i in 0..<output.count {
                    outputArray.append(output[i].doubleValue)
                }
                result(outputArray)
            } else {
                result(FlutterError(code: "INFERENCE_ERROR", message: "Failed to process tokens", details: nil))
            }
            
        case "generateEmbeddings":
            guard let args = call.arguments as? [String: Any],
                  let text = args["text"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing text", details: nil))
                return
            }
            
            if let embeddings = handler.generateEmbeddings(for: text) {
                // Convert to array
                var embeddingsArray: [Double] = []
                for i in 0..<embeddings.count {
                    embeddingsArray.append(embeddings[i].doubleValue)
                }
                result(embeddingsArray)
            } else {
                result(FlutterError(code: "EMBEDDING_ERROR", message: "Failed to generate embeddings", details: nil))
            }
            
        case "processBatch":
            guard let args = call.arguments as? [String: Any],
                  let tokenBatches = args["tokenBatches"] as? [[Int]] else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing tokenBatches", details: nil))
                return
            }
            
            let batches = tokenBatches.map { batch in
                batch.map { Int32($0) }
            }
            
            handler.processBatch(batches) { outputs in
                let results = outputs.map { output -> [Double]? in
                    guard let output = output else { return nil }
                    var array: [Double] = []
                    for i in 0..<output.count {
                        array.append(output[i].doubleValue)
                    }
                    return array
                }
                result(results)
            }
            
        case "getPerformanceMetrics":
            let metrics = handler.getPerformanceMetrics()
            result(metrics)
            
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

// MARK: - Helper Extensions

extension MLMultiArray {
    subscript(indices: [Int]) -> NSNumber {
        get {
            let nsIndices = indices.map { NSNumber(value: $0) }
            return self[nsIndices]
        }
        set {
            let nsIndices = indices.map { NSNumber(value: $0) }
            self[nsIndices] = newValue
        }
    }
}