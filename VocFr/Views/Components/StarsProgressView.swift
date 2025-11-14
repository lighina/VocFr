//
//  StarsProgressView.swift
//  VocFr
//
//  Created by Claude on 14/11/2025.
//  Part B.1: Stars Progress Display
//

import SwiftUI
import SwiftData

struct StarsProgressView: View {
    let modelContext: ModelContext

    var body: some View {
        let totalStars = PointsManager.shared.getTotalStars(from: modelContext)
        let streak = PointsManager.shared.getCurrentStreak(from: modelContext)
        let nextUnlock = PointsManager.shared.getNextUnlockRequirement(from: modelContext)

        VStack(spacing: 12) {
            // Current stars
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title)

                Text("\(totalStars)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("星")
                    .font(.title3)
                    .foregroundColor(.secondary)

                Spacer()

                // Streak badge
                if streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(streak)天")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
            }

            // Next unlock info
            if let (uniteNumber, starsRequired) = nextUnlock {
                let starsNeeded = starsRequired - totalStars
                let progress = Double(totalStars) / Double(starsRequired)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("下一解锁：Unité \(uniteNumber)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("还需 \(starsNeeded) 星")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)

                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * min(progress, 1.0), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            } else {
                Text("🎉 所有单元已解锁！")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                       AudioFile.self, AudioSegment.self, UserProgress.self,
                                       WordProgress.self, PracticeRecord.self, SectionWord.self,
                                       configurations: config)

    let context = container.mainContext

    // Create sample data
    let userProgress = UserProgress()
    userProgress.totalStars = 35
    userProgress.currentStreak = 5
    context.insert(userProgress)

    return StarsProgressView(modelContext: context)
        .padding()
        .modelContainer(container)
}
