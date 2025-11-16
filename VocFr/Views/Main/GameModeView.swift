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

                // Available sections for games
                VStack(alignment: .leading, spacing: 12) {
                    Text("game.select.section".localized)
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

// Section for each Unite's games
struct UniteGameSection: View {
    let unite: Unite
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Unite header
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Unité \(unite.number)")
                        .font(.headline)

                    Text(unite.title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

            // Sections list
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(unite.sections.sorted(by: { $0.orderIndex < $1.orderIndex })) { section in
                        NavigationLink(destination: HangmanGameView(section: section)) {
                            HStack {
                                Image(systemName: "gamecontroller")
                                    .foregroundColor(.purple)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(section.name.capitalized)
                                        .font(.body)
                                        .foregroundColor(.primary)

                                    Text("game.hangman".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        GameModeView()
            .modelContainer(for: [Unite.self, Section.self, Word.self])
    }
}
