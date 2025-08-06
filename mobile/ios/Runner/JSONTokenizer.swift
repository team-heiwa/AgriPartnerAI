import Foundation

@available(iOS 16.0, *)
class JSONTokenizer {
    private var vocabulary: [String: Int] = [:]
    private var reverseVocabulary: [Int: String] = [:]
    private let unkId = 3
    private let bosId = 2
    private let eosId = 1
    private let padId = 0
    
    init?(jsonPath: String) {
        if !loadJSON(from: jsonPath) {
            return nil
        }
    }
    
    private func loadJSON(from path: String) -> Bool {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let model = json["model"] as? [String: Any],
               let vocab = model["vocab"] as? [String: Int] {
                
                // Load vocabulary
                vocabulary = vocab
                
                // Create reverse vocabulary
                for (token, id) in vocab {
                    reverseVocabulary[id] = token
                }
                
                print("✅ Loaded JSON tokenizer with \(vocabulary.count) tokens")
                return true
            }
        } catch {
            print("❌ Failed to load JSON tokenizer: \(error)")
        }
        return false
    }
    
    func encode(_ text: String) -> [Int] {
        var tokens: [Int] = [bosId]
        
        // Simple word-based tokenization
        let words = text.components(separatedBy: .whitespaces)
        
        for (index, word) in words.enumerated() {
            // Try with space prefix for all words except first
            let processedWord = index == 0 ? word : "▁" + word
            
            if let tokenId = vocabulary[processedWord] {
                tokens.append(tokenId)
            } else if let tokenId = vocabulary[processedWord.lowercased()] {
                tokens.append(tokenId)
            } else {
                // Try without space prefix
                if let tokenId = vocabulary[word] {
                    tokens.append(tokenId)
                } else if let tokenId = vocabulary[word.lowercased()] {
                    tokens.append(tokenId)
                } else {
                    // Use unknown token
                    tokens.append(unkId)
                }
            }
        }
        
        return tokens
    }
    
    func decode(_ tokenIds: [Int]) -> String {
        var text = ""
        var previousWasWord = false
        
        for tokenId in tokenIds {
            // Skip special tokens
            if tokenId == bosId || tokenId == eosId || tokenId == padId {
                continue
            }
            
            if let token = reverseVocabulary[tokenId] {
                if token.hasPrefix("▁") {
                    // Word boundary marker
                    if previousWasWord {
                        text += " "
                    }
                    text += String(token.dropFirst())
                    previousWasWord = true
                } else if token == "<unk>" {
                    // Skip unknown tokens
                    continue
                } else if token.hasPrefix("<") && token.hasSuffix(">") {
                    // Skip special tokens
                    continue
                } else {
                    // Regular token or punctuation
                    text += token
                    previousWasWord = token.count > 1 || CharacterSet.letters.contains(token.unicodeScalars.first ?? UnicodeScalar(0))
                }
            }
        }
        
        return text.trimmingCharacters(in: .whitespaces)
    }
    
    var vocabSize: Int {
        return vocabulary.count
    }
}