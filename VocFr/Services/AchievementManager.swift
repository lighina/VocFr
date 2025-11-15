//
//  AchievementManager.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.3: Achievement System
//

import Foundation
import SwiftUI
import SwiftData

/// Manages achievement tracking and unlocking
@Observable
class AchievementManager {

    // MARK: - Singleton

    static let shared = AchievementManager()

    // MARK: - Published State

    /// Recently unlocked achievements (for displaying notifications)
    private(set) var recentlyUnlocked: [Achievement] = []

    /// Whether to show unlock notification
    private(set) var showUnlockNotification: Bool = false

    // MARK: - Private Properties

    private var modelContext: ModelContext?

    // MARK: - Initialization

    private init() {}

    /// Set the model context for database operations
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Achievement Initialization

    /// Initialize achievements in database if not already present
    func initializeAchievements(in context: ModelContext) {
        let descriptor = FetchDescriptor<Achievement>()

        do {
            let existingAchievements = try context.fetch(descriptor)

            // Only initialize if no achievements exist
            if existingAchievements.isEmpty {
                let definitions = AchievementDefinitions.createAll()
                for achievement in definitions {
                    context.insert(achievement)
                }

                try context.save()
                print("✅ Initialized \(definitions.count) achievements")
            }
        } catch {
            print("❌ Failed to initialize achievements: \(error)")
        }
    }

    // MARK: - Achievement Tracking

    /// Check and update learning milestone achievements
    func checkLearningMilestones(wordCount: Int, context: ModelContext) {
        let milestones = ["words_10", "words_50", "words_100", "words_200", "words_500"]
        checkProgressAchievements(ids: milestones, currentValue: wordCount, context: context)
    }

    /// Check and update practice count achievements
    func checkPracticeCount(practiceCount: Int, context: ModelContext) {
        let practiceIds = ["practice_5", "practice_20"]
        checkProgressAchievements(ids: practiceIds, currentValue: practiceCount, context: context)
    }

    /// Check for perfect practice achievements
    func checkPerfectPractice(perfectCount: Int, isPerfect20: Bool, context: ModelContext) {
        // Check "10 perfect practices" achievement
        checkProgressAchievements(ids: ["perfect_10"], currentValue: perfectCount, context: context)

        // Check "single perfect 20/20" achievement
        if isPerfect20 {
            checkProgressAchievements(ids: ["perfect_single_20"], currentValue: 1, context: context)
        }
    }

    /// Check and update streak achievements
    func checkStreak(currentStreak: Int, context: ModelContext) {
        let streakIds = ["streak_3", "streak_7", "streak_30", "streak_100"]
        checkProgressAchievements(ids: streakIds, currentValue: currentStreak, context: context)
    }

    /// Check and update points achievements
    func checkPoints(totalPoints: Int, context: ModelContext) {
        let pointsIds = ["stars_100", "stars_500", "stars_1000"]
        checkProgressAchievements(ids: pointsIds, currentValue: totalPoints, context: context)
    }

    /// Check exploration achievements
    func checkUnitUnlocked(unlockedCount: Int, context: ModelContext) {
        checkProgressAchievements(ids: ["unlock_unit_1"], currentValue: unlockedCount, context: context)
    }

    func checkSectionCompleted(completedCount: Int, context: ModelContext) {
        checkProgressAchievements(ids: ["complete_section_10"], currentValue: completedCount, context: context)
    }

    func checkUnitCompleted(completedCount: Int, context: ModelContext) {
        checkProgressAchievements(ids: ["complete_unit_1"], currentValue: completedCount, context: context)
    }

    /// Check special time-based achievements
    func checkSpecialAchievements(context: ModelContext) {
        let hour = Calendar.current.component(.hour, from: Date())

        // Early bird (practice between 5 AM - 8 AM)
        if hour >= 5 && hour < 8 {
            checkProgressAchievements(ids: ["early_bird"], currentValue: 1, context: context)
        }

        // Night owl (practice between 10 PM - 2 AM)
        if hour >= 22 || hour < 2 {
            checkProgressAchievements(ids: ["night_owl"], currentValue: 1, context: context)
        }
    }

    /// Check speed run achievement (complete practice in under 60 seconds with 100% accuracy)
    func checkSpeedRun(timeSpent: TimeInterval, accuracy: Double, context: ModelContext) {
        if timeSpent < 60 && accuracy >= 1.0 {
            checkProgressAchievements(ids: ["speed_run"], currentValue: 1, context: context)
        }
    }

    /// Check birthday achievement (practice on account creation anniversary)
    func checkBirthday(userCreationDate: Date, context: ModelContext) {
        let calendar = Calendar.current
        let today = Date()

        let creationComponents = calendar.dateComponents([.month, .day], from: userCreationDate)
        let todayComponents = calendar.dateComponents([.month, .day], from: today)

        if creationComponents.month == todayComponents.month &&
           creationComponents.day == todayComponents.day {
            checkProgressAchievements(ids: ["birthday"], currentValue: 1, context: context)
        }
    }

    // MARK: - Helper Methods

    /// Generic method to check and update progress-based achievements
    private func checkProgressAchievements(ids: [String], currentValue: Int, context: ModelContext) {
        for id in ids {
            guard let achievement = fetchAchievement(id: id, context: context) else { continue }

            // Update progress
            let wasUnlocked = achievement.updateProgress(currentValue)

            if wasUnlocked {
                handleAchievementUnlock(achievement, context: context)
            }
        }

        // Save changes
        do {
            try context.save()
        } catch {
            print("❌ Failed to save achievement progress: \(error)")
        }
    }

    /// Fetch achievement by ID
    private func fetchAchievement(id: String, context: ModelContext) -> Achievement? {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate { $0.id == id },
            fetchLimit: 1
        )

        do {
            let achievements = try context.fetch(descriptor)
            return achievements.first
        } catch {
            print("❌ Failed to fetch achievement \(id): \(error)")
            return nil
        }
    }

    /// Handle achievement unlock
    private func handleAchievementUnlock(_ achievement: Achievement, context: ModelContext) {
        print("🏆 Achievement unlocked: \(achievement.titleKey)")

        // Award points
        if achievement.pointsReward > 0 {
            PointsManager.shared.awardStars(
                points: achievement.pointsReward,
                modelContext: context,
                reason: "Achievement unlocked: \(achievement.titleKey)"
            )
        }

        // Add to recently unlocked for notification
        recentlyUnlocked.append(achievement)
        showUnlockNotification = true

        // Auto-hide notification after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.dismissUnlockNotification()
        }
    }

    /// Dismiss unlock notification
    func dismissUnlockNotification() {
        showUnlockNotification = false

        // Clear recently unlocked after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.recentlyUnlocked.removeAll()
        }
    }

    // MARK: - Fetch Methods

    /// Fetch all achievements
    func fetchAllAchievements(context: ModelContext) -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>(
            sortBy: [
                SortDescriptor(\Achievement.category),
                SortDescriptor(\Achievement.orderIndex)
            ]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch achievements: \(error)")
            return []
        }
    }

    /// Fetch achievements by category
    func fetchAchievements(category: AchievementCategory, context: ModelContext) -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate { $0.category == category },
            sortBy: [SortDescriptor(\Achievement.orderIndex)]
        )

        do {
            return try context.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch achievements for category \(category): \(error)")
            return []
        }
    }

    /// Get achievement statistics
    func getStatistics(context: ModelContext) -> (total: Int, unlocked: Int, inProgress: Int) {
        let all = fetchAllAchievements(context: context)
        let unlocked = all.filter { $0.isUnlocked }.count
        let inProgress = all.filter { $0.isInProgress }.count

        return (total: all.count, unlocked: unlocked, inProgress: inProgress)
    }

    /// Get completion percentage
    func getCompletionPercentage(context: ModelContext) -> Int {
        let stats = getStatistics(context: context)
        guard stats.total > 0 else { return 0 }
        return Int(Double(stats.unlocked) / Double(stats.total) * 100)
    }
}
