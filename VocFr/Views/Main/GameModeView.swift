//
//  GameModeView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Game mode selection view
//

import SwiftUI
import SwiftData

struct GameModeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unites: [Unite]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)

                    Text("game.mode.title".localized)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("game.mode.subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)

                // Matching Game - All Learned Words
                VStack(spacing: 12) {
                    Text("游戏列表")
                        .font(.headline)
                        .padding(.horizontal)

                    NavigationLink(destination: AllWordsMatchingGameView(unites: unites.filter { $0.isUnlocked })) {
                        GameCard(
                            icon: "square.grid.2x2.fill",
                            title: "配对游戏",
                            description: "从所有学过的词汇中配对 (10对)",
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal)

                // Hangman Game by Unite
                VStack(alignment: .leading, spacing: 12) {
                    Text("吊人游戏 - 按单元选择")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(unites.sorted(by: { $0.number < $1.number })) { unite in
                        if unite.isUnlocked {
                            UniteGameSection(unite: unite)
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("main.game.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Unite game card - directly link to Hangman with all words from the Unite
struct UniteGameSection: View {
    let unite: Unite

    // Count total words in this unite
    private var totalWords: Int {
        var count = 0
        for section in unite.sections {
            count += section.sectionWords.count
        }
        return count
    }

    var body: some View {
        NavigationLink(destination: HangmanGameView(unite: unite)) {
            HStack {
                // Icon
                Image(systemName: "figure.stand")
                    .font(.system(size: 30))
                    .foregroundColor(.purple)
                    .frame(width: 50)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unité \(unite.number)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(unite.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("\(totalWords) mots")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal)
    }
}

// Game Card Component
struct GameCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        GameModeView()
            .modelContainer(for: [Unite.self, Section.self, Word.self])
    }
}
