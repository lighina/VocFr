//
//  GamesListView.swift
//  VocFr
//
//  Created by Claude on 17/11/2025.
//  Games list view with unlock functionality
//

import SwiftUI
import SwiftData

struct GamesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \GameMode.orderIndex) private var gameModes: [GameMode]
    @Query private var userProgress: [UserProgress]

    @State private var showUnlockAlert = false
    @State private var selectedGame: GameMode?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("🎮")
                        .font(.system(size: 60))

                    Text("games.title".localized)
                        .font(.title)
                        .fontWeight(.bold)

                    Text("games.subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Games Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(gameModes) { game in
                        GameModeCard(
                            game: game,
                            currentGems: currentGems,
                            onTap: {
                                handleGameTap(game)
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("games.navigation.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("games.unlock.title".localized, isPresented: $showUnlockAlert) {
            Button("games.unlock.cancel".localized, role: .cancel) {
                selectedGame = nil
            }
            Button("games.unlock.confirm".localized) {
                if let game = selectedGame {
                    unlockGame(game)
                }
            }
        } message: {
            if let game = selectedGame {
                Text(String(format: "games.unlock.message".localized, game.name, game.requiredGems))
            }
        }
    }

    // MARK: - Computed Properties

    private var currentGems: Int {
        userProgress.first?.totalGems ?? 0
    }

    // MARK: - Methods

    private func handleGameTap(_ game: GameMode) {
        if game.isUnlocked {
            // Navigate to game
            // This will be handled by NavigationLink in GameCard
        } else {
            // Show unlock alert
            selectedGame = game
            showUnlockAlert = true
        }
    }

    private func unlockGame(_ game: GameMode) {
        let success = PointsManager.shared.unlockGameMode(game, modelContext: modelContext)

        if success {
            print("🎮 Unlocked game: \(game.name)")
        } else {
            print("❌ Failed to unlock game: Not enough gems")
        }

        selectedGame = nil
    }
}

// MARK: - Game Mode Card

struct GameModeCard: View {
    let game: GameMode
    let currentGems: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(game.isUnlocked ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)

                    if game.isUnlocked {
                        Image(systemName: game.iconName)
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }
                }

                // Title
                VStack(spacing: 4) {
                    Text(game.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)

                    Text(game.nameInChinese)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Description
                Text(game.descriptionText)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 30)

                // Status
                if game.isUnlocked {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("games.status.unlocked".localized)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                } else {
                    HStack(spacing: 4) {
                        Text("💎")
                            .font(.caption)
                        Text("\(game.requiredGems)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(currentGems >= game.requiredGems ? .cyan : .red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.cyan.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GamesListView()
            .modelContainer(for: [GameMode.self, UserProgress.self], inMemory: true)
    }
}
