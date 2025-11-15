//
//  FlashcardViewModel.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.2: Flashcard Mode - State Management
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel for Flashcard review session
@Observable
class FlashcardViewModel {

    // MARK: - Dependencies

    let section: Section
    private var modelContext: ModelContext?

    // MARK: - State

    /// All cards in review queue
    private(set) var reviewQueue: [Word] = []

    /// Original review queue for restart
    private var originalReviewQueue: [Word] = []

    /// Current card index
    private(set) var currentIndex: Int = 0

    /// Whether current card is flipped
    var isFaceUp: Bool = false

    /// Total cards reviewed in this session
    private(set) var reviewedCount: Int = 0

    /// Cards marked as known in this session
    private(set) var knownCount: Int = 0

    /// Whether review session is completed
    private(set) var isCompleted: Bool = false

    /// Statistics for the section
    private(set) var statistics: FlashcardStatistics?

    // MARK: - Computed Properties

    /// Current word being reviewed
    var currentWord: Word? {
        guard currentIndex < reviewQueue.count else { return nil }
        return reviewQueue[currentIndex]
    }

    /// Remaining cards in queue
    var remainingCards: Int {
        reviewQueue.count - currentIndex
    }

    /// Progress text (e.g., "5/20")
    var progressText: String {
        "\(currentIndex + 1)/\(reviewQueue.count)"
    }

    /// Progress percentage (0.0 to 1.0)
    var progressPercentage: Double {
        guard reviewQueue.count > 0 else { return 0.0 }
        return Double(currentIndex) / Double(reviewQueue.count)
    }

    /// Success rate in this session
    var sessionSuccessRate: Double {
        guard reviewedCount > 0 else { return 0.0 }
        return Double(knownCount) / Double(reviewedCount)
    }

    /// Section name
    var sectionName: String {
        section.name
    }

    // MARK: - Initialization

    init(section: Section, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
        loadReviewQueue()
        loadStatistics()
    }

    // MARK: - Setup

    /// Set or update the model context
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        // Reload queue and statistics with new context
        if reviewQueue.isEmpty {
            loadReviewQueue()
            loadStatistics()
        }
    }

    // MARK: - Queue Management

    /// Load cards due for review
    private func loadReviewQueue() {
        guard let modelContext = modelContext else {
            print("⚠️ ModelContext not available")
            return
        }

        reviewQueue = FlashcardManager.shared.getDueCards(section: section, context: modelContext)
        originalReviewQueue = reviewQueue // Save original queue for restart
        print("📚 Loaded \(reviewQueue.count) cards for review")

        if reviewQueue.isEmpty {
            isCompleted = true
        }
    }

    /// Load statistics for the section
    private func loadStatistics() {
        guard let modelContext = modelContext else { return }
        statistics = FlashcardManager.shared.getStatistics(section: section, context: modelContext)
    }

    // MARK: - Review Actions

    /// Mark current card as known (move to next box)
    func markAsKnown() {
        guard let word = currentWord, let modelContext = modelContext else { return }

        FlashcardManager.shared.markAsKnown(wordId: word.id, context: modelContext)

        reviewedCount += 1
        knownCount += 1

        print("✅ Marked as known: \(word.canonical)")

        moveToNextCard()
    }

    /// Mark current card as unknown (move to box 1)
    func markAsUnknown() {
        guard let word = currentWord, let modelContext = modelContext else { return }

        FlashcardManager.shared.markAsUnknown(wordId: word.id, context: modelContext)

        reviewedCount += 1

        print("❌ Marked as unknown: \(word.canonical)")

        moveToNextCard()
    }

    /// Move to next card in queue
    private func moveToNextCard() {
        // Reset flip state
        isFaceUp = false

        // Move to next card
        currentIndex += 1

        // Check if completed
        if currentIndex >= reviewQueue.count {
            completeReview()
        }
    }

    /// Complete the review session
    private func completeReview() {
        isCompleted = true

        guard let modelContext = modelContext else { return }

        // Award daily completion bonus if all due cards are done
        if FlashcardManager.shared.checkDailyGoalCompleted(section: section, context: modelContext) {
            FlashcardManager.shared.awardDailyCompletionBonus(context: modelContext)
            print("🎉 Daily review completed! Bonus awarded.")
        }

        // Track achievements
        trackAchievements()

        // Save practice record
        savePracticeRecord()

        print("✨ Review session completed: \(reviewedCount) cards, \(knownCount) known")
    }

    /// Restart the review session
    func restartReview() {
        currentIndex = 0
        reviewedCount = 0
        knownCount = 0
        isCompleted = false
        isFaceUp = false
        // Restore original queue instead of reloading from database
        reviewQueue = originalReviewQueue
        loadStatistics()
        print("🔄 Restarting review with \(reviewQueue.count) cards")
    }

    // MARK: - Persistence

    /// Save practice record
    private func savePracticeRecord() {
        guard let modelContext = modelContext, reviewedCount > 0 else { return }

        let accuracy = sessionSuccessRate
        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Flashcard Review",
            wordsStudied: reviewedCount,
            accuracy: accuracy,
            timeSpent: 0 // Not tracking time for flashcards
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            print("✅ Flashcard session saved: \(reviewedCount) cards reviewed")
        } catch {
            print("❌ Failed to save flashcard session: \(error)")
        }
    }

    /// Track achievements
    private func trackAchievements() {
        guard let modelContext = modelContext else { return }

        // Get practice count
        let descriptor = FetchDescriptor<PracticeRecord>()
        if let allRecords = try? modelContext.fetch(descriptor) {
            AchievementManager.shared.checkPracticeCount(
                practiceCount: allRecords.count,
                context: modelContext
            )
        }

        // Check for perfect practice
        if sessionSuccessRate >= 1.0 && reviewedCount >= 5 {
            let perfectDescriptor = FetchDescriptor<PracticeRecord>(
                predicate: #Predicate { $0.accuracy >= 1.0 }
            )
            if let perfectRecords = try? modelContext.fetch(perfectDescriptor) {
                AchievementManager.shared.checkPerfectPractice(
                    perfectCount: perfectRecords.count,
                    isPerfect20: reviewedCount >= 20,
                    context: modelContext
                )
            }
        }

        // Check points achievements
        if let userProgress = try? modelContext.fetch(FetchDescriptor<UserProgress>()).first {
            AchievementManager.shared.checkPoints(
                totalPoints: userProgress.totalStars,
                context: modelContext
            )
        }

        // Check learning milestones
        let wordProgressDescriptor = FetchDescriptor<WordProgress>(
            predicate: #Predicate { $0.lastReviewed != nil }
        )
        if let wordProgresses = try? modelContext.fetch(wordProgressDescriptor) {
            AchievementManager.shared.checkLearningMilestones(
                wordCount: wordProgresses.count,
                context: modelContext
            )
        }
    }
}
