//
//  VocabularyDataLoader.swift
//  VocFr
//
//  Created by Claude on 11/11/2025.
//

import Foundation
import SwiftData

/// Loads vocabulary data from JSON files
class VocabularyDataLoader {

    // MARK: - JSON Structures

    private struct MetadataJSON: Codable {
        let version: String
        let lastUpdated: String
        let description: String
        let totalUnites: Int
        let availableUnites: [Int]
        let dataFormat: String
        let audioFormat: String
    }

    private struct VocabularyJSON: Codable {
        let version: String
        let lastUpdated: String
        let description: String
        let unites: [UniteJSON]
    }

    private struct UniteJSON: Codable {
        let id: String
        let number: Int
        let title: String
        let isUnlocked: Bool
        let requiredStars: Int
        let requiredGems: Int?  // Optional for backward compatibility
        let sections: [SectionJSON]
    }

    private struct SectionJSON: Codable {
        let id: String
        let name: String
        let orderIndex: Int
        let words: [WordJSON]
    }

    private struct WordJSON: Codable {
        let canonical: String
        let chinese: String
        let partOfSpeech: String
        let genderOrPos: String
        let category: String
        let elision: Bool
        let german: String?          // Optional for backward compatibility
        let type: String?            // "vocabulary", "expression", "sentence"
        let nameOfImage: String?     // Custom image name or null for no image
    }

    // MARK: - Public Methods

    /// Load vocabulary data from JSON files
    /// - Returns: Array of Unite objects
    /// - Throws: Loading or parsing errors
    static func loadVocabularyData() throws -> [Unite] {
        guard let metadataURL = findFile(name: "metadata", extension: "json") else {
            throw DataLoaderError.fileNotFound("metadata.json not found in bundle")
        }

        print("📦 Loading vocabulary data (metadata.json + Unite*.json)")
        return try loadSplitFormat(metadataURL: metadataURL)
    }

    // MARK: - Private Loading Methods

    /// Load vocabulary from split files (metadata.json + Unite*.json)
    private static func loadSplitFormat(metadataURL: URL) throws -> [Unite] {
        // Read metadata
        let metadataData = try Data(contentsOf: metadataURL)
        let decoder = JSONDecoder()
        let metadata = try decoder.decode(MetadataJSON.self, from: metadataData)

        print("📖 Metadata version: \(metadata.version)")
        print("📅 Last updated: \(metadata.lastUpdated)")
        print("📊 Total unités: \(metadata.totalUnites)")
        print("🎯 Data format: \(metadata.dataFormat)")

        // Load each unite file
        var globalWordCache: [String: Word] = [:]
        var unites: [Unite] = []

        for uniteNumber in metadata.availableUnites.sorted() {
            guard let uniteURL = findFile(name: "Unite\(uniteNumber)", extension: "json") else {
                print("⚠️  Warning: Unite\(uniteNumber).json not found, skipping")
                continue
            }

            let uniteData = try Data(contentsOf: uniteURL)
            let uniteJSON = try decoder.decode(UniteJSON.self, from: uniteData)
            let unite = convertToUnite(from: uniteJSON, wordCache: &globalWordCache)
            unites.append(unite)

            let wordCount = unite.sections.reduce(0) { $0 + $1.sectionWords.count }
            print("  ✅ Loaded Unite \(uniteNumber): \(unite.title) (\(wordCount) words)")
        }

        print("✅ Successfully loaded \(unites.count) unités with \(globalWordCache.count) unique words")
        return unites
    }

    /// Find a file in bundle (searches root and Data/JSON subdirectory)
    private static func findFile(name: String, extension ext: String) -> URL? {
        // Try root directory first
        if let rootURL = Bundle.main.url(forResource: name, withExtension: ext) {
            return rootURL
        }
        // Try Data/JSON subdirectory
        if let subdirURL = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Data/JSON") {
            return subdirURL
        }
        return nil
    }

    // MARK: - Private Conversion Methods

    private static func convertToUnite(from json: UniteJSON, wordCache: inout [String: Word]) -> Unite {
        let unite = Unite(
            id: json.id,
            number: json.number,
            title: json.title,
            isUnlocked: json.isUnlocked,
            requiredStars: json.requiredStars,
            requiredGems: json.requiredGems ?? 0  // Default to 0 if not specified
        )

        // Convert sections
        unite.sections = json.sections.map { sectionJSON in
            convertToSection(from: sectionJSON, unite: unite, wordCache: &wordCache)
        }

        // Set reverse relationships
        for section in unite.sections {
            section.unite = unite
        }

        return unite
    }

    private static func convertToSection(from json: SectionJSON, unite: Unite, wordCache: inout [String: Word]) -> Section {
        let section = Section(
            id: json.id,
            name: json.name,
            orderIndex: json.orderIndex
        )

        // Convert words
        var sectionWords: [SectionWord] = []

        for (index, wordJSON) in json.words.enumerated() {
            // Create unique cache key: canonical + partOfSpeech + chinese
            // This ensures words with same spelling but different meanings
            // (e.g., "café" coffee vs. "café" coffee shop) are treated as separate entities
            let cacheKey = "\(wordJSON.canonical)-\(wordJSON.partOfSpeech)-\(wordJSON.chinese)"

            // Check cache first
            let word: Word
            if let cachedWord = wordCache[cacheKey] {
                word = cachedWord
            } else {
                // Create new word
                word = convertToWord(from: wordJSON)
                wordCache[cacheKey] = word
            }

            // Create SectionWord relationship
            let sectionWord = SectionWord(orderIndex: index)
            sectionWord.section = section
            sectionWord.word = word

            sectionWords.append(sectionWord)
        }

        section.sectionWords = sectionWords

        return section
    }

    private static func convertToWord(from json: WordJSON) -> Word {
        // Determine part of speech
        let partOfSpeech: PartOfSpeech
        switch json.partOfSpeech.lowercased() {
        case "noun": partOfSpeech = .noun
        case "verb": partOfSpeech = .verb
        case "adjective": partOfSpeech = .adjective
        case "number": partOfSpeech = .number
        case "pronoun": partOfSpeech = .pronoun
        case "preposition": partOfSpeech = .preposition
        default: partOfSpeech = .other
        }

        // Determine image name
        // Priority: 1. Use nameOfImage from JSON if provided
        //          2. Fall back to normalized canonical + "_image"
        // Special: "none", "null", or empty string = no image (for expressions/sentences)
        let imageName: String
        if let customImageName = json.nameOfImage, !customImageName.isEmpty {
            let trimmed = customImageName.trimmingCharacters(in: .whitespaces).lowercased()

            // Check for special "no image" markers
            if trimmed == "none" || trimmed == "null" {
                imageName = ""  // Empty string indicates no image
            } else {
                // Use custom image name from JSON (supports homonyms)
                // e.g., "orange_color_image.png" vs "orange_fruit_image.png"
                imageName = customImageName.replacingOccurrences(of: ".png", with: "")
                                          .replacingOccurrences(of: ".jpg", with: "")
            }
        } else {
            // Fall back to default naming (normalized, ASCII-only)
            imageName = normalizeForAssetName(json.canonical) + "_image"
        }

        // Generate unique ID: canonical + partOfSpeech + chinese
        // This ensures words with same spelling but different meanings
        // (e.g., "café" coffee vs. "café" coffee shop) have unique IDs
        let wordId = "\(json.canonical)-\(json.partOfSpeech)-\(json.chinese)"

        let word = Word(
            id: wordId,
            canonical: json.canonical,
            chinese: json.chinese,
            imageName: imageName,
            partOfSpeech: partOfSpeech,
            category: json.category
        )

        // Generate word forms
        word.forms = generateWordForms(
            canonical: json.canonical,
            genderOrPos: json.genderOrPos,
            partOfSpeech: partOfSpeech,
            elision: json.elision
        )

        return word
    }

    private static func generateWordForms(
        canonical: String,
        genderOrPos: String,
        partOfSpeech: PartOfSpeech,
        elision: Bool
    ) -> [WordForm] {
        var forms: [WordForm] = []

        // Only generate forms for nouns
        guard partOfSpeech == .noun else {
            return []
        }

        let gender: Gender? = genderOrPos == "masculine" ? .masculine : (genderOrPos == "feminine" ? .feminine : nil)

        guard let gender = gender else {
            return []
        }

        // Indefinite article (singular)
        let indefiniteArticle = elision ? "un" : (gender == .masculine ? "un" : "une")
        forms.append(WordForm(
            formType: .indefiniteArticle,
            french: "\(indefiniteArticle) \(canonical)",
            articleOnly: indefiniteArticle,
            gender: gender,
            number: .singular,
            isMainForm: true
        ))

        // Definite article (singular)
        let definiteArticle: String
        if elision {
            definiteArticle = "l'"
        } else {
            definiteArticle = gender == .masculine ? "le" : "la"
        }
        forms.append(WordForm(
            formType: .definiteArticle,
            french: "\(definiteArticle)\(elision ? "" : " ")\(canonical)",
            articleOnly: definiteArticle,
            gender: gender,
            number: .singular,
            isMainForm: false
        ))

        // Plural forms
        let pluralNoun = canonical.hasSuffix("s") || canonical.hasSuffix("x") || canonical.hasSuffix("z")
            ? canonical
            : canonical + "s"

        forms.append(WordForm(
            formType: .indefiniteArticle,
            french: "des \(pluralNoun)",
            articleOnly: "des",
            gender: gender,
            number: .plural,
            isMainForm: false
        ))

        forms.append(WordForm(
            formType: .definiteArticle,
            french: "les \(pluralNoun)",
            articleOnly: "les",
            gender: gender,
            number: .plural,
            isMainForm: false
        ))

        return forms
    }

    /// Normalize French text for asset filenames (remove accents, spaces, etc.)
    private static func normalizeForAssetName(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "é", with: "e")
            .replacingOccurrences(of: "è", with: "e")
            .replacingOccurrences(of: "ê", with: "e")
            .replacingOccurrences(of: "ë", with: "e")
            .replacingOccurrences(of: "à", with: "a")
            .replacingOccurrences(of: "â", with: "a")
            .replacingOccurrences(of: "ä", with: "a")
            .replacingOccurrences(of: "ô", with: "o")
            .replacingOccurrences(of: "ö", with: "o")
            .replacingOccurrences(of: "ù", with: "u")
            .replacingOccurrences(of: "û", with: "u")
            .replacingOccurrences(of: "ü", with: "u")
            .replacingOccurrences(of: "ï", with: "i")
            .replacingOccurrences(of: "î", with: "i")
            .replacingOccurrences(of: "ç", with: "c")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "'", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }
}

// MARK: - Error Types

enum DataLoaderError: Error, LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let message): return "File not found: \(message)"
        case .decodingFailed(let message): return "Decoding failed: \(message)"
        case .invalidData(let message): return "Invalid data: \(message)"
        }
    }
}
