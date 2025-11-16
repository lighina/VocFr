//
//  LanguageManager.swift
//  VocFr
//
//  Created by Claude on 14/11/2025.
//  Part B.2.3: Language Manager
//

import Foundation
import SwiftUI

/// Supported languages in the app
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case chinese = "zh-Hans"
    case french = "fr"
    case spanish = "es"
    case german = "de"
    case italian = "it"
    case portuguese = "pt"

    var id: String { rawValue }

    /// Display name in the language itself
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .chinese:
            return "中文"
        case .french:
            return "Français"
        case .spanish:
            return "Español"
        case .german:
            return "Deutsch"
        case .italian:
            return "Italiano"
        case .portuguese:
            return "Português"
        }
    }

    /// Flag emoji for the language
    var flag: String {
        switch self {
        case .english:
            return "🇬🇧"
        case .chinese:
            return "🇨🇳"
        case .french:
            return "🇫🇷"
        case .spanish:
            return "🇪🇸"
        case .german:
            return "🇩🇪"
        case .italian:
            return "🇮🇹"
        case .portuguese:
            return "🇵🇹"
        }
    }

    /// Language code for bundle localization
    var code: String {
        rawValue
    }
}

/// Manager for app language preferences and localization
@Observable
class LanguageManager {

    // MARK: - Singleton

    static let shared = LanguageManager()

    // MARK: - Properties

    /// Current selected language
    var currentLanguage: AppLanguage {
        didSet {
            saveLanguagePreference()
            updateBundle()
        }
    }

    /// Bundle for the current language
    private var languageBundle: Bundle?

    // MARK: - Constants

    private let languageKey = "AppLanguage"

    // MARK: - Initialization

    private init() {
        // Load saved language preference or use system default
        if let savedLanguage = UserDefaults.standard.string(forKey: languageKey),
           let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            // Auto-detect system language and match to supported languages
            let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"

            switch systemLanguage {
            case "zh":
                self.currentLanguage = .chinese
            case "fr":
                self.currentLanguage = .french
            case "es":
                self.currentLanguage = .spanish
            case "de":
                self.currentLanguage = .german
            case "it":
                self.currentLanguage = .italian
            case "pt":
                self.currentLanguage = .portuguese
            default:
                // Default to English for all other languages
                self.currentLanguage = .english
            }
        }

        updateBundle()
    }

    // MARK: - Public Methods

    /// Set the app language
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
    }

    /// Get localized string for a key
    func localizedString(_ key: String, comment: String = "") -> String {
        if let bundle = languageBundle {
            return bundle.localizedString(forKey: key, value: nil, table: nil)
        }
        return NSLocalizedString(key, comment: comment)
    }

    /// Get localized string with format arguments
    func localizedString(_ key: String, _ arguments: CVarArg...) -> String {
        let format = localizedString(key)
        return String(format: format, arguments: arguments)
    }

    // MARK: - Private Methods

    /// Save language preference to UserDefaults
    private func saveLanguagePreference() {
        UserDefaults.standard.set(currentLanguage.rawValue, forKey: languageKey)
    }

    /// Update the language bundle
    private func updateBundle() {
        if let path = Bundle.main.path(forResource: currentLanguage.code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            self.languageBundle = bundle
        } else {
            self.languageBundle = Bundle.main
        }
    }
}

// MARK: - String Extension Update

extension String {
    /// Returns the localized string for this key using LanguageManager
    var localized: String {
        LanguageManager.shared.localizedString(self)
    }

    /// Returns the localized string with format arguments using LanguageManager
    func localized(_ arguments: CVarArg...) -> String {
        let format = LanguageManager.shared.localizedString(self)
        return String(format: format, arguments: arguments)
    }
}
