//
//  Achievement.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.3: Achievement System
//

import Foundation
import SwiftData

/// Achievement category for organizing achievements
enum AchievementCategory: String, Codable {
    case learning = "Learning Milestones"
    case practice = "Practice Master"
    case streak = "Consistency"
    case points = "Star Collector"
    case exploration = "Explorer"
    case special = "Special"
}

/// Achievement rarity/difficulty level
enum AchievementTier: String, Codable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"
}

/// Achievement model - represents a single achievement in the system
@Model
final class Achievement {

    // MARK: - Properties

    /// Unique identifier (e.g., "words_10", "practice_perfect_10")
    @Attribute(.unique) var id: String

    /// Display title (localized key)
    var titleKey: String

    /// Description (localized key)
    var descriptionKey: String

    /// Achievement category
    var category: AchievementCategory

    /// Achievement tier/rarity
    var tier: AchievementTier

    /// System icon name
    var iconName: String

    /// Target value to unlock (e.g., 100 for "100 words learned")
    var targetValue: Int

    /// Current progress towards target
    var currentProgress: Int

    /// Whether achievement is unlocked
    var isUnlocked: Bool

    /// Date when achievement was unlocked (nil if not unlocked)
    var unlockedDate: Date?

    /// Points awarded when unlocked
    var pointsReward: Int

    /// Display order within category
    var orderIndex: Int

    // MARK: - Computed Properties

    /// Progress percentage (0-100)
    var progressPercentage: Int {
        guard targetValue > 0 else { return 0 }
        return min(100, Int(Double(currentProgress) / Double(targetValue) * 100))
    }

    /// Is achievement in progress (some progress but not unlocked)
    var isInProgress: Bool {
        !isUnlocked && currentProgress > 0
    }

    // MARK: - Initialization

    init(
        id: String,
        titleKey: String,
        descriptionKey: String,
        category: AchievementCategory,
        tier: AchievementTier,
        iconName: String,
        targetValue: Int,
        currentProgress: Int = 0,
        pointsReward: Int = 0,
        orderIndex: Int = 0
    ) {
        self.id = id
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
        self.category = category
        self.tier = tier
        self.iconName = iconName
        self.targetValue = targetValue
        self.currentProgress = currentProgress
        self.isUnlocked = false
        self.unlockedDate = nil
        self.pointsReward = pointsReward
        self.orderIndex = orderIndex
    }

    // MARK: - Methods

    /// Update progress and check if achievement should unlock
    func updateProgress(_ newProgress: Int) -> Bool {
        guard !isUnlocked else { return false }

        currentProgress = newProgress

        if currentProgress >= targetValue {
            unlock()
            return true
        }

        return false
    }

    /// Unlock the achievement
    func unlock() {
        guard !isUnlocked else { return }
        isUnlocked = true
        unlockedDate = Date()
    }

    /// Reset achievement (for testing)
    func reset() {
        isUnlocked = false
        unlockedDate = nil
        currentProgress = 0
    }
}

// MARK: - Achievement Definitions

/// Factory for creating achievement definitions
struct AchievementDefinitions {

    /// Create all achievement definitions
    static func createAll() -> [Achievement] {
        var achievements: [Achievement] = []

        // MARK: - Learning Milestones
        achievements += [
            Achievement(
                id: "words_10",
                titleKey: "achievement.words.10.title",
                descriptionKey: "achievement.words.10.description",
                category: .learning,
                tier: .bronze,
                iconName: "book.fill",
                targetValue: 10,
                pointsReward: 5,
                orderIndex: 0
            ),
            Achievement(
                id: "words_50",
                titleKey: "achievement.words.50.title",
                descriptionKey: "achievement.words.50.description",
                category: .learning,
                tier: .silver,
                iconName: "books.vertical.fill",
                targetValue: 50,
                pointsReward: 10,
                orderIndex: 1
            ),
            Achievement(
                id: "words_100",
                titleKey: "achievement.words.100.title",
                descriptionKey: "achievement.words.100.description",
                category: .learning,
                tier: .gold,
                iconName: "text.book.closed.fill",
                targetValue: 100,
                pointsReward: 20,
                orderIndex: 2
            ),
            Achievement(
                id: "words_200",
                titleKey: "achievement.words.200.title",
                descriptionKey: "achievement.words.200.description",
                category: .learning,
                tier: .platinum,
                iconName: "graduationcap.fill",
                targetValue: 200,
                pointsReward: 50,
                orderIndex: 3
            ),
            Achievement(
                id: "words_500",
                titleKey: "achievement.words.500.title",
                descriptionKey: "achievement.words.500.description",
                category: .learning,
                tier: .diamond,
                iconName: "crown.fill",
                targetValue: 500,
                pointsReward: 100,
                orderIndex: 4
            )
        ]

        // MARK: - Practice Achievements
        achievements += [
            Achievement(
                id: "practice_5",
                titleKey: "achievement.practice.5.title",
                descriptionKey: "achievement.practice.5.description",
                category: .practice,
                tier: .bronze,
                iconName: "figure.run",
                targetValue: 5,
                pointsReward: 5,
                orderIndex: 0
            ),
            Achievement(
                id: "practice_20",
                titleKey: "achievement.practice.20.title",
                descriptionKey: "achievement.practice.20.description",
                category: .practice,
                tier: .silver,
                iconName: "figure.strengthtraining.traditional",
                targetValue: 20,
                pointsReward: 15,
                orderIndex: 1
            ),
            Achievement(
                id: "perfect_10",
                titleKey: "achievement.perfect.10.title",
                descriptionKey: "achievement.perfect.10.description",
                category: .practice,
                tier: .gold,
                iconName: "star.circle.fill",
                targetValue: 10,
                pointsReward: 25,
                orderIndex: 2
            ),
            Achievement(
                id: "perfect_single_20",
                titleKey: "achievement.perfect.single.title",
                descriptionKey: "achievement.perfect.single.description",
                category: .practice,
                tier: .platinum,
                iconName: "medal.fill",
                targetValue: 1,
                pointsReward: 30,
                orderIndex: 3
            )
        ]

        // MARK: - Streak Achievements
        achievements += [
            Achievement(
                id: "streak_3",
                titleKey: "achievement.streak.3.title",
                descriptionKey: "achievement.streak.3.description",
                category: .streak,
                tier: .bronze,
                iconName: "flame.fill",
                targetValue: 3,
                pointsReward: 5,
                orderIndex: 0
            ),
            Achievement(
                id: "streak_7",
                titleKey: "achievement.streak.7.title",
                descriptionKey: "achievement.streak.7.description",
                category: .streak,
                tier: .silver,
                iconName: "flame.fill",
                targetValue: 7,
                pointsReward: 15,
                orderIndex: 1
            ),
            Achievement(
                id: "streak_30",
                titleKey: "achievement.streak.30.title",
                descriptionKey: "achievement.streak.30.description",
                category: .streak,
                tier: .gold,
                iconName: "flame.fill",
                targetValue: 30,
                pointsReward: 50,
                orderIndex: 2
            ),
            Achievement(
                id: "streak_100",
                titleKey: "achievement.streak.100.title",
                descriptionKey: "achievement.streak.100.description",
                category: .streak,
                tier: .diamond,
                iconName: "flame.fill",
                targetValue: 100,
                pointsReward: 200,
                orderIndex: 3
            )
        ]

        // MARK: - Points Achievements
        achievements += [
            Achievement(
                id: "stars_100",
                titleKey: "achievement.stars.100.title",
                descriptionKey: "achievement.stars.100.description",
                category: .points,
                tier: .bronze,
                iconName: "star.fill",
                targetValue: 100,
                pointsReward: 10,
                orderIndex: 0
            ),
            Achievement(
                id: "stars_500",
                titleKey: "achievement.stars.500.title",
                descriptionKey: "achievement.stars.500.description",
                category: .points,
                tier: .silver,
                iconName: "sparkles",
                targetValue: 500,
                pointsReward: 25,
                orderIndex: 1
            ),
            Achievement(
                id: "stars_1000",
                titleKey: "achievement.stars.1000.title",
                descriptionKey: "achievement.stars.1000.description",
                category: .points,
                tier: .gold,
                iconName: "sparkle",
                targetValue: 1000,
                pointsReward: 50,
                orderIndex: 2
            )
        ]

        // MARK: - Exploration Achievements
        achievements += [
            Achievement(
                id: "unlock_unit_1",
                titleKey: "achievement.unlock.unit.title",
                descriptionKey: "achievement.unlock.unit.description",
                category: .exploration,
                tier: .bronze,
                iconName: "lock.open.fill",
                targetValue: 1,
                pointsReward: 10,
                orderIndex: 0
            ),
            Achievement(
                id: "complete_section_10",
                titleKey: "achievement.complete.section.10.title",
                descriptionKey: "achievement.complete.section.10.description",
                category: .exploration,
                tier: .silver,
                iconName: "checkmark.circle.fill",
                targetValue: 10,
                pointsReward: 20,
                orderIndex: 1
            ),
            Achievement(
                id: "complete_unit_1",
                titleKey: "achievement.complete.unit.title",
                descriptionKey: "achievement.complete.unit.description",
                category: .exploration,
                tier: .gold,
                iconName: "checkmark.seal.fill",
                targetValue: 1,
                pointsReward: 50,
                orderIndex: 2
            )
        ]

        // MARK: - Special Achievements
        achievements += [
            Achievement(
                id: "early_bird",
                titleKey: "achievement.early.bird.title",
                descriptionKey: "achievement.early.bird.description",
                category: .special,
                tier: .silver,
                iconName: "sunrise.fill",
                targetValue: 1,
                pointsReward: 15,
                orderIndex: 0
            ),
            Achievement(
                id: "night_owl",
                titleKey: "achievement.night.owl.title",
                descriptionKey: "achievement.night.owl.description",
                category: .special,
                tier: .silver,
                iconName: "moon.stars.fill",
                targetValue: 1,
                pointsReward: 15,
                orderIndex: 1
            ),
            Achievement(
                id: "speed_run",
                titleKey: "achievement.speed.run.title",
                descriptionKey: "achievement.speed.run.description",
                category: .special,
                tier: .platinum,
                iconName: "bolt.fill",
                targetValue: 1,
                pointsReward: 30,
                orderIndex: 2
            ),
            Achievement(
                id: "birthday",
                titleKey: "achievement.birthday.title",
                descriptionKey: "achievement.birthday.description",
                category: .special,
                tier: .gold,
                iconName: "gift.fill",
                targetValue: 1,
                pointsReward: 20,
                orderIndex: 3
            )
        ]

        return achievements
    }
}
