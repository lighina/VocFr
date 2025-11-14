//
//  LocalizationHelper.swift
//  VocFr
//
//  Created by Claude on 14/11/2025.
//  Part B.2: Basic Internationalization
//

import Foundation

/// Extension to make localization easier
extension String {
    /// Returns the localized string for this key
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    /// Returns the localized string with format arguments
    func localized(_ arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
}
