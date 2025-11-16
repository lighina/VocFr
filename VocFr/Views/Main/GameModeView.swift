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
    @State private var isHangmanExpanded: Bool = false

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

                // Games List
                VStack(spacing: 12) {
                    Text("game.mode.games.list".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    // Matching Game
                    NavigationLink(destination: AllWordsMatchingGameView(unites: unites.filter { $0.isUnlocked })) {
                        GameCard(
                            icon: "square.grid.2x2.fill",
                            title: "Matching",
                            description: "game.mode.matching.subtitle".localized,
                            color: .orange
                        )
                    }
                    .padding(.horizontal)

                    // Hangman Game (Expandable)
                    VStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                isHangmanExpanded.toggle()
                            }
                        }) {
                            GameCard(
                                icon: "figure.stand",
                                title: "Hangman",
                                description: "game.mode.hangman.subtitle".localized,
                                color: .purple,
                                isExpandable: true,
                                isExpanded: isHangmanExpanded
                            )
                        }
                        .padding(.horizontal)

                        // Expandable Unite List
                        if isHangmanExpanded {
                            VStack(spacing: 8) {
                                // All Learned Words Option
                                NavigationLink(destination: HangmanAllWordsView(unites: unites.filter { $0.isUnlocked })) {
                                    UniteGameRow(
                                        icon: "books.vertical.fill",
                                        title: "game.mode.hangman.all.words".localized,
                                        subtitle: "",
                                        wordCount: totalWordsCount(),
                                        color: .blue
                                    )
                                }
                                .padding(.horizontal)

                                // Unite List
                                ForEach(unites.sorted(by: { $0.number < $1.number })) { unite in
                                    if unite.isUnlocked {
                                        NavigationLink(destination: HangmanGameView(unite: unite)) {
                                            UniteGameRow(
                                                icon: "book.fill",
                                                title: "Unité \(unite.number)",
                                                subtitle: unite.title,
                                                wordCount: countWordsInUnite(unite),
                                                color: .purple
                                            )
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("main.game.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func totalWordsCount() -> Int {
        var count = 0
        for unite in unites where unite.isUnlocked {
            for section in unite.sections {
                count += section.sectionWords.count
            }
        }
        return count
    }

    private func countWordsInUnite(_ unite: Unite) -> Int {
        var count = 0
        for section in unite.sections {
            count += section.sectionWords.count
        }
        return count
    }
}

// Game Card Component
struct GameCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    var isExpandable: Bool = false
    var isExpanded: Bool = false

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

                if !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isExpandable {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
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

// Unite Game Row Component
struct UniteGameRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let wordCount: Int
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                // First line: Title : Subtitle (if subtitle exists)
                if !subtitle.isEmpty {
                    Text("\(title) : \(subtitle)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                } else {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }

                // Second line: word count
                Text(String(format: "game.mode.words.count".localized, wordCount))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.2), lineWidth: 1)
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
