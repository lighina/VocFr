//
//  AchievementRowView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.3: Achievement System - Row Component
//

import SwiftUI

struct AchievementRowView: View {
    let achievement: Achievement
    let onClaim: (() -> Void)?

    init(achievement: Achievement, onClaim: (() -> Void)? = nil) {
        self.achievement = achievement
        self.onClaim = onClaim
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 60, height: 60)

                Image(systemName: achievement.iconName)
                    .font(.system(size: 28))
                    .foregroundColor(iconColor)
            }
            .opacity(achievement.isUnlocked ? 1.0 : (achievement.isReadyToClaim ? 1.0 : 0.5))

            // Info
            VStack(alignment: .leading, spacing: 6) {
                // Title with tier badge
                HStack(spacing: 8) {
                    Text(achievement.titleKey.localized)
                        .font(.headline)
                        .foregroundColor(achievement.isUnlocked ? .primary : .secondary)

                    // Tier badge
                    Text(achievement.tier.rawValue)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(tierColor)
                        .cornerRadius(8)
                }

                // Description
                Text(achievement.descriptionKey.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Progress bar or status
                if achievement.isUnlocked {
                    // Unlocked: show date and rewards
                    HStack(spacing: 12) {
                        if let unlockedDate = achievement.unlockedDate {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(formatDate(unlockedDate))
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }

                        // Show rewards that were earned
                        if achievement.pointsReward > 0 {
                            HStack(spacing: 2) {
                                Text("⭐")
                                Text("+\(achievement.pointsReward)")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }

                        if achievement.gemsReward > 0 {
                            HStack(spacing: 2) {
                                Text("💎")
                                Text("+\(achievement.gemsReward)")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                    }
                } else {
                    // Not unlocked yet
                    VStack(alignment: .leading, spacing: 4) {
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.systemGray5))
                                    .frame(height: 6)

                                // Progress
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(tierColor)
                                    .frame(
                                        width: geometry.size.width * CGFloat(achievement.progressPercentage) / 100,
                                        height: 6
                                    )
                            }
                        }
                        .frame(height: 6)

                        // Progress text and rewards
                        HStack(spacing: 8) {
                            Text("\(achievement.currentProgress) / \(achievement.targetValue)")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            // Show available rewards
                            if achievement.pointsReward > 0 {
                                HStack(spacing: 2) {
                                    Text("⭐")
                                    Text("\(achievement.pointsReward)")
                                }
                                .font(.caption2)
                                .foregroundColor(.orange)
                            }

                            if achievement.gemsReward > 0 {
                                HStack(spacing: 2) {
                                    Text("💎")
                                    Text("\(achievement.gemsReward)")
                                }
                                .font(.caption2)
                                .foregroundColor(.cyan)
                            }
                        }
                    }
                }
            }

            Spacer()

            // Claim button (if ready to claim)
            if achievement.isReadyToClaim {
                Button(action: {
                    onClaim?()
                }) {
                    Text("Claim")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [.orange, .pink]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(achievement.isUnlocked ? 1.0 : (achievement.isReadyToClaim ? 1.0 : 0.5)))
                .overlay(
                    achievement.isReadyToClaim && !achievement.isUnlocked ?
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(LinearGradient(
                            gradient: Gradient(colors: [.orange, .pink]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ), lineWidth: 2)
                    : nil
                )
        )
    }

    // MARK: - Styling

    private var tierColor: Color {
        switch achievement.tier {
        case .bronze:
            return Color.brown
        case .silver:
            return Color.gray
        case .gold:
            return Color.yellow
        case .platinum:
            return Color.cyan
        case .diamond:
            return Color.purple
        }
    }

    private var iconBackgroundColor: Color {
        if achievement.isUnlocked || achievement.isReadyToClaim {
            return tierColor.opacity(0.2)
        } else {
            return Color(.systemGray5)
        }
    }

    private var iconColor: Color {
        if achievement.isUnlocked || achievement.isReadyToClaim {
            return tierColor
        } else {
            return Color(.systemGray3)
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 16) {
        // Unlocked achievement
        AchievementRowView(
            achievement: {
                let a = Achievement(
                    id: "words_100",
                    titleKey: "Word Master",
                    descriptionKey: "Learn 100 words",
                    category: .learning,
                    tier: .gold,
                    iconName: "text.book.closed.fill",
                    targetValue: 100,
                    currentProgress: 100,
                    pointsReward: 20,
                    gemsReward: 5
                )
                a.unlock()
                return a
            }()
        )

        // Ready to claim
        AchievementRowView(
            achievement: Achievement(
                id: "words_50",
                titleKey: "Bookworm",
                descriptionKey: "Learn 50 words",
                category: .learning,
                tier: .silver,
                iconName: "books.vertical.fill",
                targetValue: 50,
                currentProgress: 50,
                pointsReward: 10,
                gemsReward: 3
            ),
            onClaim: {
                print("Claimed!")
            }
        )

        // In progress achievement
        AchievementRowView(
            achievement: Achievement(
                id: "words_30",
                titleKey: "Learning",
                descriptionKey: "Learn 30 words",
                category: .learning,
                tier: .silver,
                iconName: "books.vertical.fill",
                targetValue: 50,
                currentProgress: 35,
                pointsReward: 10,
                gemsReward: 2
            )
        )

        // Locked achievement
        AchievementRowView(
            achievement: Achievement(
                id: "words_10",
                titleKey: "First Steps",
                descriptionKey: "Learn 10 words",
                category: .learning,
                tier: .bronze,
                iconName: "book.fill",
                targetValue: 10,
                currentProgress: 0,
                pointsReward: 5
            )
        )
    }
    .padding()
}
