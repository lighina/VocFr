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
    @Query private var userProgressList: [UserProgress]
    @Query private var unites: [Unite]

    private var userProgress: UserProgress? {
        userProgressList.first
    }

    private var totalStars: Int {
        userProgress?.totalStars ?? 0
    }

    private var streak: Int {
        userProgress?.currentStreak ?? 0
    }

    private var nextUnlock: (uniteNumber: Int, starsRequired: Int)? {
        let lockedUnites = unites
            .filter { !$0.isUnlocked }
            .sorted { $0.number < $1.number }

        return lockedUnites.first.map { ($0.number, $0.requiredStars) }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Current stars
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.title)

                Text("\(totalStars)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("stars.label".localized)
                    .font(.title3)
                    .foregroundColor(.secondary)

                Spacer()

                // Streak badge
                if streak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("stars.streak.days".localized(streak))
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
                        Text("stars.next.unlock".localized(uniteNumber))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("stars.need.more".localized(starsNeeded))
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
                Text("stars.all.unlocked".localized)
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

    return StarsProgressView()
        .padding()
        .modelContainer(container)
}
