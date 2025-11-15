//
//  FlashcardManager.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.2: Flashcard Mode - Queue Management
//

import Foundation
import SwiftData

/// Manager for flashcard review queue and Leitner system
@Observable
class FlashcardManager {
    static let shared = FlashcardManager()

    private init() {}

    // MARK: - Queue Management

    /// Get cards due for review today from a section
    func getDueCards(section: Section, context: ModelContext) -> [Word] {
        let sectionWords = section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }

        var dueWords: [Word] = []

        for word in sectionWords {
            if let progress = getProgress(for: word.id, context: context) {
                // Card exists - check if due
                if progress.isDueToday {
                    dueWords.append(word)
                }
            } else {
                // New card - add to queue
                dueWords.append(word)
            }
        }

        return dueWords
    }

    /// Get all cards from a section (regardless of due date) for practice
    func getAllCards(section: Section, context: ModelContext) -> [Word] {
        return section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }
    }

    /// Get all cards in a specific Leitner box
    func getCardsInBox(_ boxNumber: Int, section: Section, context: ModelContext) -> [Word] {
        let sectionWords = section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }

        return sectionWords.filter { word in
            if let progress = getProgress(for: word.id, context: context) {
                return progress.boxNumber == boxNumber
            }
            return boxNumber == 1 // New cards go to Box 1
        }
    }

    /// Get progress statistics for a section
    func getStatistics(section: Section, context: ModelContext) -> FlashcardStatistics {
        let sectionWords = section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }

        var newCards = 0
        var dueCards = 0
        var masteredCards = 0
        var boxCounts = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]

        for word in sectionWords {
            if let progress = getProgress(for: word.id, context: context) {
                boxCounts[progress.boxNumber, default: 0] += 1

                if progress.isDueToday {
                    dueCards += 1
                }

                if progress.isMastered {
                    masteredCards += 1
                }
            } else {
                newCards += 1
                boxCounts[1, default: 0] += 1
            }
        }

        return FlashcardStatistics(
            totalCards: sectionWords.count,
            newCards: newCards,
            dueCards: dueCards,
            masteredCards: masteredCards,
            boxCounts: boxCounts
        )
    }

    // MARK: - Progress Management

    /// Get or create progress for a word
    func getOrCreateProgress(for wordId: String, context: ModelContext) -> FlashcardProgress {
        if let existing = getProgress(for: wordId, context: context) {
            return existing
        }

        // Create new progress
        let progress = FlashcardProgress(wordId: wordId)
        context.insert(progress)
        return progress
    }

    /// Get existing progress for a word
    func getProgress(for wordId: String, context: ModelContext) -> FlashcardProgress? {
        var descriptor = FetchDescriptor<FlashcardProgress>(
            predicate: #Predicate { $0.wordId == wordId }
        )
        descriptor.fetchLimit = 1

        return try? context.fetch(descriptor).first
    }

    /// Mark card as known (move to next box)
    func markAsKnown(wordId: String, context: ModelContext) {
        let progress = getOrCreateProgress(for: wordId, context: context)
        let oldBox = progress.boxNumber
        progress.moveToNextBox()

        do {
            try context.save()
            print("✅ Card moved from Box \(oldBox) to Box \(progress.boxNumber)")

            // Award points for mastery
            if progress.isMastered && oldBox == 4 {
                // Just mastered (Box 4 → Box 5)
                PointsManager.shared.awardStars(
                    points: 10,
                    modelContext: context,
                    reason: "Mastered flashcard"
                )
            } else if oldBox == 0 || progress.reviewCount == 1 {
                // First time correct
                PointsManager.shared.awardStars(
                    points: 5,
                    modelContext: context,
                    reason: "Flashcard correct"
                )
            }
        } catch {
            print("❌ Failed to save flashcard progress: \(error)")
        }
    }

    /// Mark card as unknown (move to Box 1)
    func markAsUnknown(wordId: String, context: ModelContext) {
        let progress = getOrCreateProgress(for: wordId, context: context)
        let oldBox = progress.boxNumber
        progress.moveToBox1()

        do {
            try context.save()
            print("🔄 Card moved from Box \(oldBox) back to Box 1")
        } catch {
            print("❌ Failed to save flashcard progress: \(error)")
        }
    }

    /// Check if daily review goal is completed
    func checkDailyGoalCompleted(section: Section, context: ModelContext) -> Bool {
        let dueCards = getDueCards(section: section, context: context)
        return dueCards.isEmpty
    }

    /// Award bonus for completing daily review
    func awardDailyCompletionBonus(context: ModelContext) {
        PointsManager.shared.awardStars(
            points: 15,
            modelContext: context,
            reason: "Completed daily flashcard review"
        )
    }
}

// MARK: - Statistics Model

struct FlashcardStatistics {
    let totalCards: Int
    let newCards: Int
    let dueCards: Int
    let masteredCards: Int
    let boxCounts: [Int: Int]

    var remainingCards: Int {
        dueCards
    }

    var progressPercentage: Double {
        guard totalCards > 0 else { return 0.0 }
        return Double(masteredCards) / Double(totalCards)
    }
}
