import Foundation
import Flutter
import MLX
import MLXNN
import MLXRandom
import MLXLLM
import MLXLMCommon

/// Handler for Gemma MLX model - provides native on-device inference
@objc public class GemmaMLXHandler: NSObject {
    
    private var modelContainer: ModelContainer?
    private var modelConfiguration: ModelConfiguration?
    private let parameters = GenerateParameters(temperature: 0.7, topP: 0.9)
    private var isModelLoaded = false
    
    // Model paths
    private let modelBasePath: String
    
    @objc public override init() {
        // Get documents directory for model storage
        let documentsPath = FileManager.default.urls(for: .documentDirectory, 
                                                     in: .userDomainMask).first!
        self.modelBasePath = documentsPath.appendingPathComponent("models/gemma-3n-E4B").path
        super.init()
    }
    
    // MARK: - Model Loading
    
    /// Load Gemma model from local storage
    @objc public func loadModel(completion: @escaping (Bool, String?) -> Void) {
        Task {
            do {
                // Check if model files exist
                guard FileManager.default.fileExists(atPath: modelBasePath) else {
                    completion(false, "Model files not found at \(modelBasePath)")
                    return
                }
                
                // Set GPU cache limit for memory management
                MLX.GPU.set(cacheLimit: 20 * 1024 * 1024) // 20MB cache
                
                // Load model configuration
                let configPath = "\(modelBasePath)/config.json"
                let config = try loadModelConfig(from: configPath)
                self.modelConfiguration = config
                
                // Load the model container
                print("Loading Gemma MLX model from \(modelBasePath)")
                let (model, tokenizer) = try await LLM.load(
                    modelPath: modelBasePath,
                    configuration: config
                )
                
                self.modelContainer = ModelContainer(model: model, tokenizer: tokenizer)
                self.isModelLoaded = true
                
                print("Gemma MLX model loaded successfully")
                completion(true, nil)
                
            } catch {
                print("Failed to load Gemma MLX model: \(error)")
                completion(false, error.localizedDescription)
            }
        }
    }
    
    // MARK: - Text Generation
    
    /// Generate text from prompt using MLX
    @objc public func generateText(
        prompt: String,
        maxTokens: Int = 200,
        temperature: Double = 0.7,
        completion: @escaping (String?, String?) -> Void
    ) {
        guard isModelLoaded, let container = modelContainer else {
            completion(nil, "Model not loaded")
            return
        }
        
        Task {
            do {
                // Update generation parameters
                var params = self.parameters
                params.temperature = Float(temperature)
                
                // Tokenize the prompt
                let promptTokens = try await container.tokenizer.encode(text: prompt)
                
                // Generate response
                let result = try await container.model.generate(
                    promptTokens: promptTokens,
                    parameters: params,
                    maxTokens: maxTokens
                ) { tokens in
                    // Progress callback - decode partial results
                    if let partial = try? container.tokenizer.decode(tokens: tokens) {
                        print("Generating: \(partial)")
                    }
                    return .continue
                }
                
                // Decode final result
                let generatedText = try container.tokenizer.decode(tokens: result)
                completion(generatedText, nil)
                
            } catch {
                print("Text generation failed: \(error)")
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    // MARK: - Chat Interface
    
    /// Chat with conversation history
    @objc public func chat(
        message: String,
        history: [[String: String]]?,
        systemPrompt: String = "You are Kei, a helpful agricultural AI assistant.",
        completion: @escaping (String?, String?) -> Void
    ) {
        guard isModelLoaded, let container = modelContainer else {
            completion(nil, "Model not loaded")
            return
        }
        
        Task {
            do {
                // Build conversation with history
                var messages: [Message] = []
                
                // Add system prompt
                messages.append(Message(role: .system, content: systemPrompt))
                
                // Add history if provided
                if let history = history {
                    for exchange in history {
                        if let userMsg = exchange["user"] {
                            messages.append(Message(role: .user, content: userMsg))
                        }
                        if let assistantMsg = exchange["assistant"] {
                            messages.append(Message(role: .assistant, content: assistantMsg))
                        }
                    }
                }
                
                // Add current message
                messages.append(Message(role: .user, content: message))
                
                // Apply chat template
                let chatPrompt = try container.tokenizer.applyChatTemplate(messages: messages)
                
                // Generate response
                let response = try await container.model.generate(
                    promptTokens: chatPrompt,
                    parameters: parameters,
                    maxTokens: 200
                ) { _ in .continue }
                
                let responseText = try container.tokenizer.decode(tokens: response)
                completion(responseText, nil)
                
            } catch {
                print("Chat failed: \(error)")
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    // MARK: - Model Management
    
    /// Check if model files exist locally
    @objc public func checkModelExists() -> Bool {
        let requiredFiles = [
            "config.json",
            "model.safetensors",
            "tokenizer.json",
            "tokenizer_config.json"
        ]
        
        for file in requiredFiles {
            let filePath = "\(modelBasePath)/\(file)"
            if !FileManager.default.fileExists(atPath: filePath) {
                print("Missing required file: \(file)")
                return false
            }
        }
        
        return true
    }
    
    /// Download model from Hugging Face
    @objc public func downloadModel(
        progressHandler: @escaping (Double) -> Void,
        completion: @escaping (Bool, String?) -> Void
    ) {
        Task {
            do {
                // Create models directory if needed
                let modelURL = URL(fileURLWithPath: modelBasePath)
                try FileManager.default.createDirectory(
                    at: modelURL,
                    withIntermediateDirectories: true
                )
                
                // Download from Hugging Face
                let hubModel = "mlx-community/gemma-3n-E4B-it-lm-4bit"
                print("Downloading model from Hugging Face: \(hubModel)")
                
                // Use HuggingFace hub to download
                let downloader = HuggingFaceDownloader()
                try await downloader.downloadModel(
                    modelId: hubModel,
                    destination: modelURL,
                    progressHandler: progressHandler
                )
                
                print("Model downloaded successfully")
                completion(true, nil)
                
            } catch {
                print("Model download failed: \(error)")
                completion(false, error.localizedDescription)
            }
        }
    }
    
    /// Clear model from memory
    @objc public func clearModel() {
        modelContainer = nil
        modelConfiguration = nil
        isModelLoaded = false
        MLX.GPU.set(cacheLimit: 0) // Clear GPU cache
    }
    
    /// Get model info
    @objc public func getModelInfo() -> [String: Any] {
        return [
            "loaded": isModelLoaded,
            "modelPath": modelBasePath,
            "exists": checkModelExists(),
            "configuration": modelConfiguration?.description ?? "Not loaded"
        ]
    }
    
    // MARK: - Helper Methods
    
    private func loadModelConfig(from path: String) throws -> ModelConfiguration {
        let configData = try Data(contentsOf: URL(fileURLWithPath: path))
        let config = try JSONDecoder().decode(ModelConfiguration.self, from: configData)
        return config
    }
}

// MARK: - Supporting Types

struct ModelContainer {
    let model: any LanguageModel
    let tokenizer: any Tokenizer
}

struct ModelConfiguration: Codable {
    let modelType: String
    let hiddenSize: Int
    let numHiddenLayers: Int
    let numAttentionHeads: Int
    let vocabSize: Int
    let maxPositionEmbeddings: Int
    
    var description: String {
        "Type: \(modelType), Layers: \(numHiddenLayers), Hidden: \(hiddenSize)"
    }
}

struct Message {
    let role: Role
    let content: String
    
    enum Role {
        case system
        case user
        case assistant
    }
}

// MARK: - HuggingFace Downloader

class HuggingFaceDownloader {
    
    func downloadModel(
        modelId: String,
        destination: URL,
        progressHandler: @escaping (Double) -> Void
    ) async throws {
        // This is a simplified implementation
        // In production, use proper HuggingFace Hub API or git-lfs
        
        let baseURL = "https://huggingface.co/\(modelId)/resolve/main/"
        let files = [
            "config.json",
            "model.safetensors",
            "tokenizer.json",
            "tokenizer_config.json",
            "tokenizer.model"
        ]
        
        for (index, file) in files.enumerated() {
            let fileURL = URL(string: baseURL + file)!
            let destinationFile = destination.appendingPathComponent(file)
            
            // Download file
            let (tempURL, _) = try await URLSession.shared.download(from: fileURL)
            
            // Move to destination
            try FileManager.default.moveItem(at: tempURL, to: destinationFile)
            
            // Update progress
            let progress = Double(index + 1) / Double(files.count)
            progressHandler(progress)
        }
    }
}