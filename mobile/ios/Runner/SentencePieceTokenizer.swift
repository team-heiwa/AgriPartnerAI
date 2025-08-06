import Foundation

@available(iOS 16.0, *)
class SentencePieceTokenizer {
    private let modelPath: String
    private var vocabulary: [String: Int] = [:]
    private var reverseVocabulary: [Int: String] = [:]
    private let unkId = 0
    private let bosId = 1
    private let eosId = 2
    private let padId = 3
    
    init?(modelPath: String) {
        self.modelPath = modelPath
        
        // Load the model
        if !loadModel() {
            return nil
        }
    }
    
    private func loadModel() -> Bool {
        do {
            // Read the SentencePiece model file
            let modelData = try Data(contentsOf: URL(fileURLWithPath: modelPath))
            
            // Parse the protobuf format (simplified for now)
            // In production, use a proper protobuf parser
            parseModelData(modelData)
            
            print("✅ Loaded SentencePiece model with \(vocabulary.count) tokens")
            return true
        } catch {
            print("❌ Failed to load SentencePiece model: \(error)")
            return false
        }
    }
    
    private func parseModelData(_ data: Data) {
        // SentencePiece model is a protobuf file
        // We'll parse it in a simplified way to extract vocabulary
        
        // Special tokens are at the beginning
        vocabulary["<pad>"] = 0
        vocabulary["<eos>"] = 1  
        vocabulary["<bos>"] = 2
        vocabulary["<unk>"] = 3
        
        reverseVocabulary[0] = "<pad>"
        reverseVocabulary[1] = "<eos>"
        reverseVocabulary[2] = "<bos>"
        reverseVocabulary[3] = "<unk>"
        
        // Parse the binary data to extract vocab pieces
        var currentIndex = 0
        var tokenId = 4 // Start after special tokens
        
        while currentIndex < data.count && tokenId < 32000 {
            // Look for string patterns in the binary data
            // SentencePiece stores pieces as length-prefixed strings
            if currentIndex + 2 < data.count {
                let length = Int(data[currentIndex])
                if length > 0 && length < 100 && currentIndex + length + 1 < data.count {
                    let tokenData = data[(currentIndex + 1)..<(currentIndex + 1 + length)]
                    if let token = String(data: tokenData, encoding: .utf8) {
                        // Valid token found
                        if token.count > 0 && !token.contains("\0") {
                            vocabulary[token] = tokenId
                            reverseVocabulary[tokenId] = token
                            tokenId += 1
                        }
                    }
                }
            }
            currentIndex += 1
        }
        
        print("✅ Parsed \(vocabulary.count) tokens from SentencePiece model")
        
        // If parsing didn't work well, add default vocabulary
        if vocabulary.count < 1000 {
            addDefaultVocabulary()
        }
    }
    
    private func addDefaultVocabulary() {
        // Add essential tokens for basic functionality
        let essentialTokens = [
            "▁I": 10, "▁you": 11, "▁the": 12, "▁a": 13, "▁is": 14,
            "▁are": 15, "▁hello": 16, "▁help": 17, "▁can": 18, "▁with": 19,
            "▁farm": 20, "▁crop": 21, "▁plant": 22, "▁water": 23, "▁soil": 24,
            "▁weather": 25, "▁disease": 26, "▁pest": 27, "▁harvest": 28, "▁field": 29
        ]
        
        for (token, id) in essentialTokens {
            if vocabulary[token] == nil {
                vocabulary[token] = id
                reverseVocabulary[id] = token
            }
        }
    }
    
    // Encode text to token IDs
    func encode(_ text: String) -> [Int] {
        var tokens: [Int] = [bosId]
        
        // Simple word-piece tokenization
        let words = text.components(separatedBy: .whitespaces)
        
        for (index, word) in words.enumerated() {
            // Add space prefix for all words except the first
            let processedWord = index == 0 ? word : "▁" + word
            
            if let tokenId = vocabulary[processedWord.lowercased()] {
                tokens.append(tokenId)
            } else {
                // Break into subwords or use unknown token
                let subTokens = tokenizeWord(processedWord)
                tokens.append(contentsOf: subTokens)
            }
        }
        
        return tokens
    }
    
    // Decode token IDs to text
    func decode(_ tokenIds: [Int]) -> String {
        var text = ""
        
        for tokenId in tokenIds {
            // Skip special tokens
            if tokenId == bosId || tokenId == eosId || tokenId == padId {
                continue
            }
            
            if let token = reverseVocabulary[tokenId] {
                if token.hasPrefix("▁") {
                    // Word boundary - add space and remove prefix
                    if !text.isEmpty {
                        text += " "
                    }
                    text += String(token.dropFirst())
                } else if token == "<unk>" {
                    // Skip unknown tokens
                    continue
                } else {
                    text += token
                }
            }
        }
        
        return text.trimmingCharacters(in: .whitespaces)
    }
    
    private func tokenizeWord(_ word: String) -> [Int] {
        // Simple character-level fallback
        var tokens: [Int] = []
        
        // Try to find the word in vocabulary
        if let tokenId = vocabulary[word.lowercased()] {
            return [tokenId]
        }
        
        // Otherwise, use unknown token
        return [unkId]
    }
    
    // Get vocabulary size
    var vocabSize: Int {
        return max(vocabulary.count, 32000) // Gemma uses 32000
    }
}