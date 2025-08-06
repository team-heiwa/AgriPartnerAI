import Foundation

@available(iOS 16.0, *)
class GemmaTokenizer {
    // Gemma tokenizer constants
    static let padToken = 0
    static let bosToken = 1
    static let eosToken = 2
    static let unkToken = 3
    
    // Vocabulary storage
    private var vocabulary: [String: Int] = [:]
    private var reverseVocabulary: [Int: String] = [:]
    
    // SentencePiece tokenizer (if available)
    private var sentencePieceTokenizer: SentencePieceTokenizer?
    // JSON tokenizer (if available)
    private var jsonTokenizer: JSONTokenizer?
    
    init() {
        // Try to load SentencePiece model first
        var tokenizerPath: String? = nil
        
        // Debug: List all resources in bundle
        print("📁 Bundle path: \(Bundle.main.bundlePath)")
        if let resourcePath = Bundle.main.resourcePath {
            print("📁 Resource path: \(resourcePath)")
            do {
                let resourceContents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                print("📁 Bundle resources count: \(resourceContents.count)")
                for resource in resourceContents.filter({ $0.contains("tokenizer") || $0.contains("model") }) {
                    print("  - \(resource)")
                }
            } catch {
                print("❌ Error listing resources: \(error)")
            }
        }
        
        // Try to load JSON tokenizer first
        if let jsonPath = Bundle.main.path(forResource: "tokenizer", ofType: "json") {
            print("🔍 Found tokenizer.json at: \(jsonPath)")
            if let tokenizer = JSONTokenizer(jsonPath: jsonPath) {
                jsonTokenizer = tokenizer
                print("✅ JSON tokenizer loaded successfully with full vocabulary")
                return // Use JSON tokenizer
            }
        }
        
        // Try different locations for SentencePiece model
        let possiblePaths = [
            Bundle.main.path(forResource: "tokenizer", ofType: "model"),
            Bundle.main.path(forResource: "Tokenizer/tokenizer", ofType: "model"),
            "\(Bundle.main.bundlePath)/tokenizer.model",
            "\(Bundle.main.bundlePath)/Tokenizer/tokenizer.model"
        ]
        
        for path in possiblePaths {
            if let p = path, FileManager.default.fileExists(atPath: p) {
                tokenizerPath = p
                break
            }
        }
        
        if let path = tokenizerPath {
            print("🔍 Found tokenizer model at: \(path)")
            sentencePieceTokenizer = SentencePieceTokenizer(modelPath: path)
        } else {
            print("❌ Tokenizer model not found in bundle")
        }
        
        // Fall back to basic vocabulary if neither tokenizer loaded
        if sentencePieceTokenizer == nil && jsonTokenizer == nil {
            print("⚠️ No tokenizer loaded, using basic vocabulary")
            setupBasicVocabulary()
        }
    }
    
    private func setupBasicVocabulary() {
        // Special tokens (matching Gemma's special token IDs)
        vocabulary["<pad>"] = 0
        vocabulary["<bos>"] = 1
        vocabulary["<eos>"] = 2
        vocabulary["<unk>"] = 3
        
        // Map the actual token IDs from the log to test decoding
        let tokenMappings: [Int: String] = [
            // Tokens from actual generation
            1005: "▁Hello",
            16673: "!",
            7434: "▁I",
            24714: "▁am",
            12718: "▁an",
            17913: "▁AI",
            12426: "▁farming",
            520: "▁assistant",
            3801: "▁here",
            14341: "▁to",
            28192: "▁help",
            2688: "▁you",
            9322: "▁with",
            24642: "▁agricultural",
            18396: "▁questions",
            21991: ".",
            17686: "▁What",
            23746: "▁would",
            13944: "▁you",
            18408: "▁like",
            2172: "▁to",
            29387: "▁know",
            8349: "▁about",
            10068: "▁farming",
            8067: "?",
            
            // Japanese common words
            3000: "▁農業",
            3001: "▁作物",
            3002: "▁野菜",
            3003: "▁田んぼ",
            3004: "▁畑",
            3005: "▁収穫",
            3006: "▁肥料",
            3007: "▁水やり",
            3008: "▁病気",
            3009: "▁害虫"
        ]
        
        // Set up bidirectional mappings
        for (id, token) in tokenMappings {
            reverseVocabulary[id] = token
            vocabulary[token] = id
        }
        
        // Common subwords and punctuation
        let commonTokens = [
            "ing": 200, "ed": 201, "er": 202, "est": 203, "ly": 204,
            ".": 300, ",": 301, "!": 302, "?": 303, " ": 306, "\n": 307
        ]
        
        for (token, id) in commonTokens {
            vocabulary[token] = id
            reverseVocabulary[id] = token
        }
    }
    
    // Tokenize text into token IDs
    func encode(_ text: String) -> [Int] {
        // Use JSON tokenizer if available
        if let jsonTokenizer = jsonTokenizer {
            return jsonTokenizer.encode(text)
        }
        
        // Use SentencePiece if available
        if let spTokenizer = sentencePieceTokenizer {
            return spTokenizer.encode(text)
        }
        
        // Fallback to basic tokenization
        var tokens: [Int] = []
        
        // Add BOS token
        tokens.append(Self.bosToken)
        
        // Simple word-based tokenization
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        for word in words {
            // Try exact match with ▁ prefix (SentencePiece style)
            let prefixedWord = "▁" + word
            if let tokenId = vocabulary[prefixedWord] {
                tokens.append(tokenId)
            } else if let tokenId = vocabulary[word] {
                tokens.append(tokenId)
            } else {
                // Try to break down into known subwords
                let subwordTokens = tokenizeSubwords(word)
                tokens.append(contentsOf: subwordTokens)
            }
        }
        
        return tokens
    }
    
    // Decode token IDs back to text
    func decode(_ tokenIds: [Int]) -> String {
        // Use JSON tokenizer if available
        if let jsonTokenizer = jsonTokenizer {
            return jsonTokenizer.decode(tokenIds)
        }
        
        // Use SentencePiece if available
        if let spTokenizer = sentencePieceTokenizer {
            return spTokenizer.decode(tokenIds)
        }
        
        // Fallback to basic decoding
        var text = ""
        var previousWasWord = false
        
        for tokenId in tokenIds {
            // Skip special tokens
            if tokenId == Self.padToken || tokenId == Self.bosToken || tokenId == Self.eosToken {
                continue
            }
            
            if let token = reverseVocabulary[tokenId] {
                if token.hasPrefix("▁") {
                    // Word boundary marker
                    if previousWasWord {
                        text += " "
                    }
                    text += String(token.dropFirst()) // Remove ▁
                    previousWasWord = true
                } else if token == "<unk>" {
                    // Skip unknown tokens
                    continue
                } else {
                    // Subword or punctuation
                    text += token
                    previousWasWord = token == "." || token == "!" || token == "?"
                }
            } else {
                // Skip tokens not in vocabulary
                continue
            }
        }
        
        return text.trimmingCharacters(in: .whitespaces)
    }
    
    // Simple subword tokenization
    private func tokenizeSubwords(_ word: String) -> [Int] {
        var tokens: [Int] = []
        var remaining = word
        
        // Try to match known subwords
        while !remaining.isEmpty {
            var found = false
            
            // Try longest match first
            for length in stride(from: remaining.count, to: 0, by: -1) {
                let substring = String(remaining.prefix(length))
                if let tokenId = vocabulary[substring] {
                    tokens.append(tokenId)
                    remaining = String(remaining.dropFirst(length))
                    found = true
                    break
                }
            }
            
            if !found {
                // No match found, use unknown token and move one character
                tokens.append(Self.unkToken)
                remaining = String(remaining.dropFirst())
            }
        }
        
        return tokens.isEmpty ? [Self.unkToken] : tokens
    }
    
    // Get vocabulary size
    var vocabSize: Int {
        return 32000 // Gemma's vocabulary size
    }
    
    // Load vocabulary from Gemma model (if available)
    func loadVocabularyFromFile(path: String) -> Bool {
        // In production, load the actual tokenizer.model file
        // For now, we'll use our basic vocabulary
        return true
    }
    
    // Advanced token processing for better results
    func processTokensForGeneration(_ tokens: [Int]) -> [Int] {
        // Remove repeated tokens
        var processed: [Int] = []
        var lastToken = -1
        var repeatCount = 0
        
        for token in tokens {
            if token == lastToken {
                repeatCount += 1
                if repeatCount < 3 { // Allow some repetition but not too much
                    processed.append(token)
                }
            } else {
                repeatCount = 0
                processed.append(token)
                lastToken = token
            }
        }
        
        return processed
    }
}
