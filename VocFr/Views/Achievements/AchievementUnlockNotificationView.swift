//
//  AchievementUnlockNotificationView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.3: Achievement System - Unlock Notification
//

import SwiftUI

struct AchievementUnlockNotificationView: View {
    let achievement: Achievement
    let onDismiss: () -> Void

    @State private var animationScale: CGFloat = 0.5
    @State private var animationOpacity: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            // Achievement icon with glow effect
            ZStack {
                // Glow background
                Circle()
                    .fill(tierColor.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)

                // Icon background
                Circle()
                    .fill(tierColor)
                    .frame(width: 80, height: 80)

                // Icon
                Image(systemName: achievement.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .scaleEffect(animationScale)

            // Achievement info
            VStack(spacing: 8) {
                Text("achievement.unlocked".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Text(achievement.titleKey.localized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(achievement.descriptionKey.localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                // Points reward
                if achievement.pointsReward > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("+\(achievement.pointsReward)")
                            .fontWeight(.semibold)
                    }
                    .font(.caption)
                }
            }
            .opacity(animationOpacity)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: tierColor.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animationScale = 1.0
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                animationOpacity = 1.0
            }
        }
        .onTapGesture {
            onDismiss()
        }
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
}

#Preview {
    let achievement = Achievement(
        id: "words_100",
        titleKey: "Word Master",
        descriptionKey: "Learn 100 words",
        category: .learning,
        tier: .gold,
        iconName: "text.book.closed.fill",
        targetValue: 100,
        pointsReward: 20
    )
    achievement.unlock()

    return ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()

        AchievementUnlockNotificationView(achievement: achievement) {
            print("Dismissed")
        }
    }
}
