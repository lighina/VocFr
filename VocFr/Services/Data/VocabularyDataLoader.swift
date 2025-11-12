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
    }

    // MARK: - Public Methods

    /// Load vocabulary data from JSON file
    /// - Returns: Array of Unite objects
    /// - Throws: Loading or parsing errors
    static func loadVocabularyData() throws -> [Unite] {
        // Load JSON file from bundle
        // Try root directory first, then subdirectory (for flexibility)
        let url: URL
        if let rootURL = Bundle.main.url(forResource: "vocabulary", withExtension: "json") {
            url = rootURL
            print("📁 Found vocabulary.json in bundle root directory")
        } else if let subdirURL = Bundle.main.url(forResource: "vocabulary", withExtension: "json", subdirectory: "Data/JSON") {
            url = subdirURL
            print("📁 Found vocabulary.json in Data/JSON subdirectory")
        } else {
            throw DataLoaderError.fileNotFound("vocabulary.json not found in bundle (searched root and Data/JSON)")
        }

        // Read file data
        let data = try Data(contentsOf: url)

        // Decode JSON
        let decoder = JSONDecoder()
        let vocabularyJSON = try decoder.decode(VocabularyJSON.self, from: data)

        print("📖 Loaded vocabulary data version: \(vocabularyJSON.version)")
        print("📅 Last updated: \(vocabularyJSON.lastUpdated)")

        // Convert JSON to SwiftData models
        var globalWordCache: [String: Word] = [:]
        let unites = vocabularyJSON.unites.map { uniteJSON in
            convertToUnite(from: uniteJSON, wordCache: &globalWordCache)
        }

        print("✅ Successfully loaded \(unites.count) unités with \(globalWordCache.count) unique words")

        return unites
    }

    // MARK: - Private Conversion Methods

    private static func convertToUnite(from json: UniteJSON, wordCache: inout [String: Word]) -> Unite {
        let unite = Unite(
            id: json.id,
            number: json.number,
            title: json.title,
            isUnlocked: json.isUnlocked,
            requiredStars: json.requiredStars
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
            // Check cache first
            let word: Word
            if let cachedWord = wordCache[wordJSON.canonical] {
                word = cachedWord
            } else {
                // Create new word
                word = convertToWord(from: wordJSON)
                wordCache[wordJSON.canonical] = word
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

        // Generate image name (normalized, ASCII-only)
        let imageName = normalizeForAssetName(json.canonical) + "_image"

        let word = Word(
            id: json.canonical,
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
