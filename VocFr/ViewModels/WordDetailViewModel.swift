//
//  WordDetailViewModel.swift
//  VocFr
//
//  Created by Claude on 13/11/2025.
//  Phase 3.2: MVVM Architecture Refactoring
//

import Foundation
import SwiftUI

/// ViewModel for Word Detail View
/// Manages word navigation, shuffle state, and word card display
@Observable
class WordDetailViewModel {

    // MARK: - Dependencies

    let section: Section

    // MARK: - State

    /// Current word index
    private(set) var currentWordIndex: Int

    /// Whether to show the word card
    private(set) var showWordCard: Bool = true

    /// Whether words are shuffled
    private(set) var isShuffled: Bool = false

    /// Shuffled word list
    private var shuffledWords: [SectionWord]

    /// Original word list (sorted by orderIndex)
    private let originalWords: [SectionWord]

    // MARK: - Computed Properties

    /// Current words to display (shuffled or original)
    var words: [SectionWord] {
        isShuffled ? shuffledWords : originalWords
    }

    /// Current word
    var currentWord: Word? {
        guard currentWordIndex >= 0 && currentWordIndex < words.count,
              let word = words[currentWordIndex].word else {
            return nil
        }
        return word
    }

    /// Can navigate to previous word
    var canGoToPrevious: Bool {
        currentWordIndex > 0
    }

    /// Can navigate to next word
    var canGoToNext: Bool {
        currentWordIndex < words.count - 1
    }

    /// Total word count
    var totalWords: Int {
        words.count
    }

    /// Current position (1-based)
    var currentPosition: Int {
        currentWordIndex + 1
    }

    // MARK: - Initialization

    init(section: Section, currentWordIndex: Int = 0) {
        self.section = section
        self.currentWordIndex = currentWordIndex

        // Initialize with sorted words
        let sortedWords = section.sectionWords.sorted(by: { $0.orderIndex < $1.orderIndex })
        self.originalWords = sortedWords
        self.shuffledWords = sortedWords.shuffled()
    }

    // MARK: - Navigation Actions

    /// Go to previous word
    func goToPrevious() {
        guard canGoToPrevious else { return }
        currentWordIndex -= 1
    }

    /// Go to next word
    func goToNext() {
        guard canGoToNext else { return }
        currentWordIndex += 1
    }

    /// Toggle shuffle mode
    func toggleShuffle() {
        isShuffled.toggle()

        // When toggling shuffle, try to maintain current word position
        if let currentWord = self.currentWord {
            // Find the same word in the new list
            let newWords = isShuffled ? shuffledWords : originalWords
            if let newIndex = newWords.firstIndex(where: { $0.word?.id == currentWord.id }) {
                currentWordIndex = newIndex
            } else {
                currentWordIndex = 0
            }
        }
    }

    /// Toggle word card visibility
    func toggleWordCard() {
        showWordCard.toggle()
    }

    /// Show word card
    func showCard() {
        showWordCard = true
    }

    /// Hide word card
    func hideCard() {
        showWordCard = false
    }

    /// Reshuffle words (only works when in shuffle mode)
    func reshuffle() {
        guard isShuffled else { return }
        shuffledWords = originalWords.shuffled()

        // Try to maintain current word
        if let currentWord = self.currentWord {
            if let newIndex = shuffledWords.firstIndex(where: { $0.word?.id == currentWord.id }) {
                currentWordIndex = newIndex
            } else {
                currentWordIndex = 0
            }
        }
    }
}
