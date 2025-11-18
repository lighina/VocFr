//
//  AchievementView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.3: Achievement System - Main View
//

import SwiftUI
import SwiftData

struct AchievementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Achievement.orderIndex)]) private var allAchievements: [Achievement]

    @State private var selectedCategory: AchievementCategory?

    // Secret entrance state
    @State private var tapCount: Int = 0
    @State private var lastTapTime: Date = Date()
    @State private var showSecretInput: Bool = false
    @State private var secretCode: String = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with stats
                    statsHeader
                        .padding(.top)

                    // Category filter
                    categoryFilter

                    // Achievements list
                    achievementsList
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
            .alert("Secret Code", isPresented: $showSecretInput) {
                TextField("Enter code", text: $secretCode)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Button("OK") {
                    executeSecretCode()
                }
                Button("Cancel", role: .cancel) {
                    secretCode = ""
                }
            } message: {
                Text("Enter the secret code")
            }
        }
    }

    // MARK: - Stats Header

    private var statsHeader: some View {
        VStack(spacing: 12) {
            // Trophy icon (secret entrance - tap 3 times)
            Image(systemName: "trophy.fill")
                .font(.system(size: 50))
                .foregroundColor(.yellow)
                .onTapGesture {
                    handleTrophyTap()
                }

            // Stats
            let stats = getStatistics()
            VStack(spacing: 4) {
                Text("\(stats.unlocked) / \(stats.total)")
                    .font(.title)
                    .fontWeight(.bold)

                Text("achievement.unlocked.count".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(stats.unlocked) / CGFloat(max(stats.total, 1)),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)

                Text("\(getCompletionPercentage())%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All button
                CategoryButton(
                    title: "achievement.category.all".localized,
                    icon: "star.fill",
                    isSelected: selectedCategory == nil
                ) {
                    selectedCategory = nil
                }

                // Category buttons
                ForEach([
                    AchievementCategory.learning,
                    .practice,
                    .streak,
                    .points,
                    .exploration,
                    .gameplayer,
                    .special
                ], id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue.localized,
                        icon: categoryIcon(category),
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    // MARK: - Achievements List

    @ViewBuilder
    private var achievementsList: some View {
        if filteredAchievements.isEmpty {
            Text("achievement.empty".localized)
                .foregroundColor(.secondary)
                .padding()
        } else {
            VStack(spacing: 16) {
                ForEach(groupedAchievements, id: \.category) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        // Category header
                        HStack {
                            Image(systemName: categoryIcon(group.category))
                                .foregroundColor(.blue)
                            Text(group.category.rawValue.localized)
                                .font(.headline)
                        }
                        .padding(.horizontal, 4)

                        // Achievements
                        VStack(spacing: 12) {
                            ForEach(group.achievements) { achievement in
                                AchievementRowView(achievement: achievement, onClaim: {
                                    claimAchievement(achievement)
                                })
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return allAchievements.filter { $0.category == category }
        }
        return allAchievements
    }

    private var groupedAchievements: [(category: AchievementCategory, achievements: [Achievement])] {
        let grouped = Dictionary(grouping: filteredAchievements) { $0.category }
        let categories: [AchievementCategory] = [.learning, .practice, .streak, .points, .exploration, .gameplayer, .special]

        return categories.compactMap { category in
            guard let achievements = grouped[category], !achievements.isEmpty else { return nil }
            return (category: category, achievements: achievements)
        }
    }

    private func getStatistics() -> (total: Int, unlocked: Int) {
        let total = allAchievements.count
        let unlocked = allAchievements.filter { $0.isUnlocked }.count
        return (total: total, unlocked: unlocked)
    }

    private func getCompletionPercentage() -> Int {
        let stats = getStatistics()
        guard stats.total > 0 else { return 0 }
        return Int(Double(stats.unlocked) / Double(stats.total) * 100)
    }

    private func categoryIcon(_ category: AchievementCategory) -> String {
        switch category {
        case .learning:
            return "book.fill"
        case .practice:
            return "figure.run"
        case .streak:
            return "flame.fill"
        case .points:
            return "star.fill"
        case .exploration:
            return "map.fill"
        case .gameplayer:
            return "gamecontroller.fill"
        case .special:
            return "sparkles"
        }
    }

    // MARK: - Achievement Actions

    /// Claim an achievement and grant rewards
    private func claimAchievement(_ achievement: Achievement) {
        // Claim the achievement and get rewards
        let rewards = achievement.claim()

        // Add rewards to user progress
        let descriptor = FetchDescriptor<UserProgress>()
        guard let userProgress = try? modelContext.fetch(descriptor).first else {
            print("⚠️ UserProgress not found")
            return
        }

        // Grant stars and gems
        if rewards.stars > 0 {
            userProgress.totalStars += rewards.stars
        }
        if rewards.gems > 0 {
            userProgress.totalGems += rewards.gems
        }

        // Save changes
        do {
            try modelContext.save()
            print("🏆 Claimed achievement: \(achievement.titleKey)")
            print("   Rewards: \(rewards.stars) ⭐, \(rewards.gems) 💎")
        } catch {
            print("❌ Failed to save achievement claim: \(error)")
        }
    }

    // MARK: - Secret Entrance

    /// Handle trophy tap for secret entrance
    private func handleTrophyTap() {
        let now = Date()
        let timeSinceLastTap = now.timeIntervalSince(lastTapTime)

        // Reset if more than 1 second between taps
        if timeSinceLastTap > 1.0 {
            tapCount = 1
        } else {
            tapCount += 1
        }

        lastTapTime = now

        // Show input after 3 taps
        if tapCount >= 3 {
            showSecretInput = true
            tapCount = 0
        }
    }

    /// Execute the secret code
    private func executeSecretCode() {
        let code = secretCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        switch code {
        case "show me the money":
            showMeTheMoney()
        case "shaoyuan":
            shaoyuanCheat()
        default:
            break
        }

        secretCode = ""
    }

    /// Cheat: Set stars and gems to 999
    private func showMeTheMoney() {
        let descriptor = FetchDescriptor<UserProgress>()
        guard let userProgress = try? modelContext.fetch(descriptor).first else { return }

        userProgress.totalStars = 999
        userProgress.totalGems = 999

        try? modelContext.save()
    }

    /// Cheat: Unlock all content and achievements
    private func shaoyuanCheat() {
        // Unlock all achievements
        for achievement in allAchievements {
            if !achievement.isUnlocked {
                achievement.isUnlocked = true
                achievement.unlockedDate = Date()
            }
        }

        // Fetch all units and unlock them
        let unitsDescriptor = FetchDescriptor<Unite>()
        if let units = try? modelContext.fetch(unitsDescriptor) {
            for unit in units {
                unit.isUnlocked = true
            }
        }

        // Unlock all game modes
        let gameModesDescriptor = FetchDescriptor<GameMode>()
        if let gameModes = try? modelContext.fetch(gameModesDescriptor) {
            for gameMode in gameModes {
                gameMode.isUnlocked = true
            }
        }

        // Unlock all storybooks
        let storybooksDescriptor = FetchDescriptor<Storybook>()
        if let storybooks = try? modelContext.fetch(storybooksDescriptor) {
            for storybook in storybooks {
                storybook.isUnlocked = true
            }
        }

        try? modelContext.save()
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

#Preview {
    AchievementView()
        .modelContainer(for: [Achievement.self], inMemory: true)
}
