//
//  FlashcardProgress.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.2: Flashcard Mode - Leitner System
//

import Foundation
import SwiftData

/// Flashcard progress tracking using Leitner spaced repetition system
@Model
final class FlashcardProgress {
    /// Word ID
    @Attribute(.unique) var wordId: String

    /// Current Leitner box (1-5)
    /// Box 1: Review daily (new cards)
    /// Box 2: Review in 2 days
    /// Box 3: Review in 4 days
    /// Box 4: Review in 7 days
    /// Box 5: Review in 14 days (mastered)
    var boxNumber: Int

    /// Last review date
    var lastReviewDate: Date

    /// Next scheduled review date
    var nextReviewDate: Date

    /// Total number of reviews
    var reviewCount: Int

    /// Number of correct answers
    var correctCount: Int

    /// Whether the card is due for review today
    var isDueToday: Bool {
        nextReviewDate <= Date()
    }

    /// Success rate (0.0 to 1.0)
    var successRate: Double {
        guard reviewCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(reviewCount)
    }

    /// Whether the card is mastered (Box 5)
    var isMastered: Bool {
        boxNumber == 5
    }

    // MARK: - Initialization

    init(wordId: String, boxNumber: Int = 1) {
        self.wordId = wordId
        self.boxNumber = boxNumber
        self.lastReviewDate = Date()
        self.nextReviewDate = Date() // Due immediately for new cards
        self.reviewCount = 0
        self.correctCount = 0
    }

    // MARK: - Leitner Box Progression

    /// Move to next box (when user knows the card)
    func moveToNextBox() {
        // Update stats
        reviewCount += 1
        correctCount += 1
        lastReviewDate = Date()

        // Move to next box (max 5)
        if boxNumber < 5 {
            boxNumber += 1
        }

        // Schedule next review based on new box
        scheduleNextReview()
    }

    /// Move back to Box 1 (when user doesn't know the card)
    func moveToBox1() {
        reviewCount += 1
        lastReviewDate = Date()
        boxNumber = 1
        scheduleNextReview()
    }

    /// Calculate and set next review date based on current box
    private func scheduleNextReview() {
        let calendar = Calendar.current
        let daysToAdd: Int

        switch boxNumber {
        case 1:
            daysToAdd = 1 // Review tomorrow
        case 2:
            daysToAdd = 2 // Review in 2 days
        case 3:
            daysToAdd = 4 // Review in 4 days
        case 4:
            daysToAdd = 7 // Review in 7 days
        case 5:
            daysToAdd = 14 // Review in 14 days (mastered)
        default:
            daysToAdd = 1
        }

        nextReviewDate = calendar.date(byAdding: .day, value: daysToAdd, to: Date()) ?? Date()
    }
}
