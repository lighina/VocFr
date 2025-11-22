//
//  Color+Theme.swift
//  VocFr
//
//  Color theme extensions for dark mode support
//

import SwiftUI

extension Color {
    // MARK: - Background Colors

    /// Primary background color (adapts to dark mode)
    static let appBackground = Color(.systemBackground)

    /// Secondary background color for cards and containers
    static let cardBackground = Color(.secondarySystemBackground)

    /// Tertiary background for nested elements
    static let tertiaryBackground = Color(.tertiarySystemBackground)

    /// Group background for list items
    static let groupedBackground = Color(.systemGroupedBackground)

    // MARK: - Text Colors

    /// Primary text color (adapts to dark mode)
    static let primaryText = Color(.label)

    /// Secondary text color for less important text
    static let secondaryText = Color(.secondaryLabel)

    /// Tertiary text color for hints and placeholders
    static let tertiaryText = Color(.tertiaryLabel)

    // MARK: - Accent Colors

    /// Primary accent color (blue)
    static let accentPrimary = Color.blue

    /// Success color (green)
    static let success = Color.green

    /// Error color (red)
    static let error = Color.red

    /// Warning color (orange)
    static let warning = Color.orange

    /// Information color (yellow)
    static let info = Color.yellow

    // MARK: - Semantic Colors

    /// Color for correct answers
    static let correct = Color.green

    /// Color for incorrect answers
    static let incorrect = Color.red

    /// Color for neutral states
    static let neutral = Color(.systemGray)

    // MARK: - Game Colors

    /// Unguessed letter background in Hangman
    static let letterUnguessed = Color(.systemGray5)

    /// Matched card background
    static let cardMatched = Color.green.opacity(0.2)

    /// Selected card background
    static let cardSelected = Color.blue.opacity(0.3)

    // MARK: - Special Character Button (Spelling Practice)

    /// Special character button background
    static let specialCharBackground = Color.blue.opacity(0.1)

    /// Special character button foreground
    static let specialCharForeground = Color.blue

    // MARK: - Separator and Border

    /// Separator line color
    static let separator = Color(.separator)

    /// Border color for containers
    static let border = Color(.systemGray4)
}

// MARK: - Backwards Compatibility Helper

extension Color {
    /// Helper to create adaptive colors from UIColor
    static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }
}
