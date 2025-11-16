//
//  WordNavigationData.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//

import Foundation

/// Navigation data for WordDetailView
struct WordNavigationData: Hashable {
    let section: Section
    let wordIndex: Int

    static func == (lhs: WordNavigationData, rhs: WordNavigationData) -> Bool {
        lhs.section.id == rhs.section.id && lhs.wordIndex == rhs.wordIndex
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(section.id)
        hasher.combine(wordIndex)
    }
}
