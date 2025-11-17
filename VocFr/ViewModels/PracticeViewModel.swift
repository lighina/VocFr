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

    /// Number of correct answers
    private(set) var correctCount: Int = 0

    /// Whether the practice session is completed
    private(set) var isCompleted: Bool = false

    /// Selected answer index (nil = not answered yet)
    private(set) var selectedAnswerIndex: Int? = nil

    /// Whether the selected answer is correct
    private(set) var isAnswerCorrect: Bool = false

    /// Shuffled options for current word (includes 1 correct + 3 distractors)
    private(set) var currentOptions: [Word] = []

    /// Points earned in this session
    private(set) var pointsEarned: Int = 0

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
        "practice.correct.count".localized(correctCount)
    }

    /// Accuracy percentage (0-100)
    var accuracyPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return Int(Double(correctCount) / Double(totalWords) * 100)
    }

    /// Section name
    var sectionName: String {
        section.name
    }

    // MARK: - Initialization

    init(section: Section, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
        generateOptions()
    }

    // MARK: - Actions

    /// Select an answer
    func selectAnswer(at index: Int) {
        guard selectedAnswerIndex == nil else { return } // Already answered

        selectedAnswerIndex = index

        // Check if answer is correct
        let selectedWord = currentOptions[index]
        isAnswerCorrect = (selectedWord.id == currentWord?.id)

        if isAnswerCorrect {
            correctCount += 1
            // Play correct answer sound
            SoundEffectManager.shared.playCorrectSound()
        } else {
            // Play incorrect answer sound
            SoundEffectManager.shared.playIncorrectSound()
        }

        // Auto advance after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.nextWord()
        }
    }

    /// Move to next word
    private func nextWord() {
        currentWordIndex += 1
        selectedAnswerIndex = nil
        isAnswerCorrect = false

        if currentWordIndex >= totalWords {
            completeSession()
        } else {
            generateOptions()
        }
    }

    /// Generate 4 options (1 correct + 3 distractors) for current word
    private func generateOptions() {
        guard let correctWord = currentWord else {
            currentOptions = []
            return
        }

        // Get all other words as potential distractors
        var distractors = words.filter { $0.id != correctWord.id }

        // Shuffle and take 3 random distractors
        distractors.shuffle()
        let selectedDistractors = Array(distractors.prefix(3))

        // Combine correct word with distractors
        var options = selectedDistractors + [correctWord]

        // Shuffle options
        options.shuffle()

        currentOptions = options
    }

    /// Complete the practice session
    private func completeSession() {
        isCompleted = true
        savePracticeRecord()
    }

    /// Restart the practice session
    func restartPractice() {
        currentWordIndex = 0
        correctCount = 0
        isCompleted = false
        selectedAnswerIndex = nil
        isAnswerCorrect = false
        pointsEarned = 0
        generateOptions()
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

            // Update WordProgress for all practiced words
            updateWordProgress(context: modelContext)

            // Award points for completing practice (Part B.1)
            let earnedPoints = calculatePoints(accuracy: accuracy)
            pointsEarned = earnedPoints
            PointsManager.shared.awardPracticePoints(accuracy: accuracy, modelContext: modelContext)

            // Track achievements
            trackAchievements(accuracy: accuracy, context: modelContext)

        } catch {
            print("❌ Failed to save practice record: \(error)")
        }
    }

    /// Update WordProgress for all words in this practice session
    private func updateWordProgress(context: ModelContext) {
        // Get or create UserProgress
        let userProgressDescriptor = FetchDescriptor<UserProgress>()
        let userProgress: UserProgress
        if let existing = try? context.fetch(userProgressDescriptor).first {
            userProgress = existing
        } else {
            userProgress = UserProgress()
            context.insert(userProgress)
        }

        for word in words {
            // Try to find existing WordProgress
            let descriptor = FetchDescriptor<WordProgress>(
                predicate: #Predicate { progress in
                    progress.word?.id == word.id
                }
            )

            if let existingProgress = try? context.fetch(descriptor).first {
                // Update existing progress
                existingProgress.lastReviewed = Date()
            } else {
                // Create new WordProgress
                let newProgress = WordProgress()
                newProgress.word = word
                newProgress.userProgress = userProgress
                newProgress.lastReviewed = Date()
                context.insert(newProgress)
            }
        }

        do {
            try context.save()
            print("✅ Updated WordProgress for \(words.count) words")
        } catch {
            print("❌ Failed to update WordProgress: \(error)")
        }
    }

    /// Track achievements for this practice session
    private func trackAchievements(accuracy: Double, context: ModelContext) {
        // Get practice count
        let descriptor = FetchDescriptor<PracticeRecord>()
        if let allRecords = try? context.fetch(descriptor) {
            AchievementManager.shared.checkPracticeCount(practiceCount: allRecords.count, context: context)
        }

        // Check for perfect practice
        if accuracy >= 1.0 {
            let perfectDescriptor = FetchDescriptor<PracticeRecord>(
                predicate: #Predicate { $0.accuracy >= 1.0 }
            )
            if let perfectRecords = try? context.fetch(perfectDescriptor) {
                let isPerfect20 = totalWords >= 20
                AchievementManager.shared.checkPerfectPractice(
                    perfectCount: perfectRecords.count,
                    isPerfect20: isPerfect20,
                    context: context
                )
            }
        }

        // Check special time-based achievements
        AchievementManager.shared.checkSpecialAchievements(context: context)

        // Check learning milestones
        let wordProgressDescriptor = FetchDescriptor<WordProgress>(
            predicate: #Predicate { $0.lastReviewed != nil }
        )
        if let wordProgresses = try? context.fetch(wordProgressDescriptor) {
            AchievementManager.shared.checkLearningMilestones(
                wordCount: wordProgresses.count,
                context: context
            )
        }
    }

    /// Calculate points based on accuracy
    private func calculatePoints(accuracy: Double) -> Int {
        let percentage = Int(accuracy * 100)

        switch percentage {
        case 90...100:
            return 20
        case 80...89:
            return 15
        case 60...79:
            return 10
        default:
            return 0
        }
    }
}
