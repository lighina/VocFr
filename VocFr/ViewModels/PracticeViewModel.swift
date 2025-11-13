//
//  PracticeViewModel.swift
//  VocFr
//
//  Created by Claude on 13/11/2025.
//  Phase 3.1: MVVM Architecture Refactoring
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel for Practice session
/// Manages practice state, progress tracking, and business logic
@Observable
class PracticeViewModel {

    // MARK: - Dependencies

    let section: Section
    private let modelContext: ModelContext?

    // MARK: - State

    /// Current word index in the practice session
    private(set) var currentWordIndex: Int = 0

    /// Whether the answer is currently shown
    private(set) var showAnswer: Bool = false

    /// Number of correct answers
    private(set) var correctCount: Int = 0

    /// Whether the practice session is completed
    private(set) var isCompleted: Bool = false

    // MARK: - Computed Properties

    /// Sorted words for this practice session
    var words: [Word] {
        section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }
    }

    /// Current word being practiced
    var currentWord: Word? {
        guard currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }

    /// Total word count
    var totalWords: Int {
        words.count
    }

    /// Progress text (e.g., "1 / 10")
    var progressText: String {
        "\(currentWordIndex + 1) / \(totalWords)"
    }

    /// Correct count text
    var correctCountText: String {
        "正确: \(correctCount)"
    }

    /// Accuracy percentage (0-100)
    var accuracyPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return Int(Double(correctCount) / Double(totalWords) * 100)
    }

    /// Accuracy text
    var accuracyText: String {
        "正确率: \(accuracyPercentage)%"
    }

    /// Results summary text
    var resultsSummaryText: String {
        "答对 \(correctCount) / \(totalWords) 个单词"
    }

    /// Section name
    var sectionName: String {
        section.name
    }

    // MARK: - Initialization

    init(section: Section, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
    }

    // MARK: - Actions

    /// Show the answer for the current word
    func showAnswerAction() {
        showAnswer = true
    }

    /// Mark current answer as correct and move to next word
    func markCorrect() {
        correctCount += 1
        nextWord()
    }

    /// Mark current answer as incorrect and move to next word
    func markIncorrect() {
        nextWord()
    }

    /// Move to next word
    private func nextWord() {
        currentWordIndex += 1
        showAnswer = false

        if currentWordIndex >= totalWords {
            completeSession()
        }
    }

    /// Complete the practice session
    private func completeSession() {
        isCompleted = true
        savePracticeRecord()
    }

    /// Restart the practice session
    func restartPractice() {
        currentWordIndex = 0
        showAnswer = false
        correctCount = 0
        isCompleted = false
    }

    // MARK: - Persistence

    /// Save practice record to database
    private func savePracticeRecord() {
        guard let modelContext = modelContext else {
            print("⚠️ ModelContext not available, skipping practice record save")
            return
        }

        let accuracy = Double(correctCount) / Double(totalWords)
        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Section Practice",
            wordsStudied: totalWords,
            accuracy: accuracy,
            timeSpent: 0 // TODO: Implement time tracking
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            print("✅ Practice record saved: \(correctCount)/\(totalWords) correct")
        } catch {
            print("❌ Failed to save practice record: \(error)")
        }
    }
}
