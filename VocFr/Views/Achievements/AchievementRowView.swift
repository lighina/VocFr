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
            .opacity(achievement.isUnlocked ? 1.0 : 0.5)

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

                // Progress bar (if not unlocked)
                if !achievement.isUnlocked {
                    VStack(alignment: .leading, spacing: 4) {
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

                        // Progress text
                        Text("\(achievement.currentProgress) / \(achievement.targetValue)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Unlocked date and reward
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

                        if achievement.pointsReward > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("+\(achievement.pointsReward)")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(achievement.isUnlocked ? 1.0 : 0.5))
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
        if achievement.isUnlocked {
            return tierColor.opacity(0.2)
        } else {
            return Color(.systemGray5)
        }
    }

    private var iconColor: Color {
        if achievement.isUnlocked {
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
                    pointsReward: 20
                )
                a.unlock()
                return a
            }()
        )

        // In progress achievement
        AchievementRowView(
            achievement: Achievement(
                id: "words_50",
                titleKey: "Bookworm",
                descriptionKey: "Learn 50 words",
                category: .learning,
                tier: .silver,
                iconName: "books.vertical.fill",
                targetValue: 50,
                currentProgress: 35,
                pointsReward: 10
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
