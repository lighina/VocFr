//
//  PointsManager.swift
//  VocFr
//
//  Created by Claude on 14/11/2025.
//  Part B.1: Stars Points System
//

import Foundation
import SwiftData

/// Manager for points/stars rewards system
class PointsManager {

    // MARK: - Singleton

    static let shared = PointsManager()
    private init() {}

    // MARK: - Points Configuration

    struct RewardPoints {
        // Practice completion rewards based on accuracy
        static let practice60to79 = 10
        static let practice80to89 = 15
        static let practice90to100 = 20

        // Section browsing reward
        static let sectionBrowse = 5

        // Daily rewards
        static let dailyLogin = 2
        static let weekStreak = 50
    }

    struct UnlockRequirements {
        static let unite2 = 50
        static let unite3 = 120
        static let unite4 = 200
        static let unite5 = 300
        static let unite6 = 420
    }

    // MARK: - Points Award Methods

    /// Award points for completing a practice session
    func awardPracticePoints(accuracy: Double, modelContext: ModelContext) {
        let points = calculatePracticePoints(accuracy: accuracy)
        addPoints(points, to: modelContext, reason: "Practice completed with \(Int(accuracy * 100))% accuracy")
    }

    /// Award points for browsing a section
    func awardSectionBrowsePoints(modelContext: ModelContext) {
        addPoints(RewardPoints.sectionBrowse, to: modelContext, reason: "Section browsed")
    }

    /// Award points for daily login
    func awardDailyLoginPoints(modelContext: ModelContext) {
        guard let userProgress = getUserProgress(from: modelContext) else { return }

        let calendar = Calendar.current
        let today = Date()

        // Check if already awarded today
        if let lastStudy = userProgress.lastStudyDate,
           calendar.isDate(lastStudy, inSameDayAs: today) {
            return // Already awarded today
        }

        // Update last study date
        userProgress.lastStudyDate = today

        // Award daily login points
        addPoints(RewardPoints.dailyLogin, to: modelContext, reason: "Daily login")

        // Update streak
        updateStreak(userProgress: userProgress, today: today, calendar: calendar)

        // Check for week streak bonus
        if userProgress.currentStreak >= 7 && userProgress.currentStreak % 7 == 0 {
            addPoints(RewardPoints.weekStreak, to: modelContext, reason: "7-day streak bonus!")
        }

        // Save changes
        try? modelContext.save()
    }

    /// Award specific amount of stars (for games and special activities)
    func awardStars(points: Int, modelContext: ModelContext, reason: String = "Game completed") {
        addPoints(points, to: modelContext, reason: reason)
    }

    // MARK: - Helper Methods

    /// Calculate points based on practice accuracy
    private func calculatePracticePoints(accuracy: Double) -> Int {
        let percentage = Int(accuracy * 100)

        switch percentage {
        case 90...100:
            return RewardPoints.practice90to100
        case 80...89:
            return RewardPoints.practice80to89
        case 60...79:
            return RewardPoints.practice60to79
        default:
            return 0 // No points for < 60%
        }
    }

    /// Add points to user progress
    private func addPoints(_ points: Int, to modelContext: ModelContext, reason: String) {
        guard points > 0 else { return }

        let userProgress = getUserProgressOrCreate(from: modelContext)
        userProgress.totalStars += points

        print("⭐ +\(points) stars! Total: \(userProgress.totalStars) (\(reason))")

        // Save changes
        try? modelContext.save()

        // Check for unit unlocks
        checkAndUnlockUnits(modelContext: modelContext, totalStars: userProgress.totalStars)
    }

    /// Get or create UserProgress
    private func getUserProgressOrCreate(from modelContext: ModelContext) -> UserProgress {
        if let existing = getUserProgress(from: modelContext) {
            return existing
        }

        // Create new UserProgress
        let newProgress = UserProgress()
        modelContext.insert(newProgress)
        return newProgress
    }

    /// Get existing UserProgress
    private func getUserProgress(from modelContext: ModelContext) -> UserProgress? {
        let descriptor = FetchDescriptor<UserProgress>()
        return try? modelContext.fetch(descriptor).first
    }

    /// Update study streak
    private func updateStreak(userProgress: UserProgress, today: Date, calendar: Calendar) {
        guard let lastStudy = userProgress.lastStudyDate else {
            // First time studying
            userProgress.currentStreak = 1
            return
        }

        let daysDifference = calendar.dateComponents([.day], from: lastStudy, to: today).day ?? 0

        if daysDifference == 1 {
            // Consecutive day
            userProgress.currentStreak += 1
        } else if daysDifference > 1 {
            // Streak broken
            userProgress.currentStreak = 1
        }
        // If daysDifference == 0, same day, no change needed
    }

    /// Check and unlock units based on total stars
    private func checkAndUnlockUnits(modelContext: ModelContext, totalStars: Int) {
        let descriptor = FetchDescriptor<Unite>(sortBy: [SortDescriptor(\.number)])
        guard let unites = try? modelContext.fetch(descriptor) else { return }

        for unite in unites {
            if !unite.isUnlocked && totalStars >= unite.requiredStars {
                unite.isUnlocked = true
                print("🎉 Unite \(unite.number) unlocked! (\(unite.title))")
            }
        }

        try? modelContext.save()
    }

    // MARK: - Query Methods

    /// Get current total stars
    func getTotalStars(from modelContext: ModelContext) -> Int {
        return getUserProgress(from: modelContext)?.totalStars ?? 0
    }

    /// Get current streak
    func getCurrentStreak(from modelContext: ModelContext) -> Int {
        return getUserProgress(from: modelContext)?.currentStreak ?? 0
    }

    /// Get required stars for next unlock
    func getNextUnlockRequirement(from modelContext: ModelContext) -> (uniteNumber: Int, starsRequired: Int)? {
        let descriptor = FetchDescriptor<Unite>(
            predicate: #Predicate<Unite> { !$0.isUnlocked },
            sortBy: [SortDescriptor(\.number)]
        )

        guard let nextLockedUnite = try? modelContext.fetch(descriptor).first else {
            return nil // All units unlocked
        }

        return (nextLockedUnite.number, nextLockedUnite.requiredStars)
    }

    // MARK: - Reset Methods

    /// Reset all stars and progress
    func resetAllStars(modelContext: ModelContext) {
        guard let userProgress = getUserProgress(from: modelContext) else { return }

        // Reset stars and streak
        userProgress.totalStars = 0
        userProgress.currentStreak = 0
        userProgress.lastStudyDate = nil

        // Lock all units except Unite 1
        let descriptor = FetchDescriptor<Unite>(sortBy: [SortDescriptor(\.number)])
        guard let unites = try? modelContext.fetch(descriptor) else { return }

        for unite in unites {
            if unite.number == 1 {
                unite.isUnlocked = true
            } else {
                unite.isUnlocked = false
            }
        }

        print("🔄 All stars and progress reset")

        try? modelContext.save()
    }
}
