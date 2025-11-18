//
//  StorybooksListView.swift
//  VocFr
//
//  Created by Claude on 17/11/2025.
//  Storybooks list view
//

import SwiftUI
import SwiftData

struct StorybooksListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Storybook.orderIndex) private var allStorybooks: [Storybook]
    @Query private var userProgress: [UserProgress]
    @Query private var unites: [Unite]

    @State private var showUnlockAlert = false
    @State private var selectedStorybook: Storybook?
    @State private var insufficientGems = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "books.vertical.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)

                    Text("storybooks.subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Storybooks List
                VStack(spacing: 16) {
                    if availableStorybooks.isEmpty {
                        Text("storybooks.empty".localized)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(availableStorybooks) { storybook in
                            StorybookCard(
                                storybook: storybook,
                                currentGems: currentGems,
                                onUnlock: {
                                    selectedStorybook = storybook
                                    attemptUnlock(storybook)
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("storybooks.navigation.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Unlock Storybook", isPresented: $showUnlockAlert) {
            Button("Cancel", role: .cancel) {
                selectedStorybook = nil
            }
            Button("Unlock with \(selectedStorybook?.requiredGems ?? 0) 💎") {
                if let storybook = selectedStorybook {
                    unlockStorybook(storybook)
                }
            }
        } message: {
            if let storybook = selectedStorybook {
                Text("Unlock \"\(storybook.title)\" with \(storybook.requiredGems) gems?")
            }
        }
        .alert("Insufficient Gems", isPresented: $insufficientGems) {
            Button("OK") {}
        } message: {
            Text("You don't have enough gems to unlock this storybook.")
        }
    }

    // MARK: - Computed Properties

    private var currentGems: Int {
        userProgress.first?.totalGems ?? 0
    }

    /// Filter storybooks to only show those whose Unite is unlocked
    private var availableStorybooks: [Storybook] {
        allStorybooks.filter { storybook in
            // Find the unite this storybook belongs to
            if let unite = unites.first(where: { $0.id == storybook.uniteId }) {
                return unite.isUnlocked
            }
            return false
        }
    }

    // MARK: - Methods

    private func attemptUnlock(_ storybook: Storybook) {
        // Check if user has enough gems
        if currentGems >= storybook.requiredGems {
            showUnlockAlert = true
        } else {
            insufficientGems = true
        }
    }

    private func unlockStorybook(_ storybook: Storybook) {
        guard let userProgress = userProgress.first else {
            print("⚠️ UserProgress not found")
            selectedStorybook = nil
            return
        }

        // Check gems again
        if userProgress.totalGems >= storybook.requiredGems {
            // Deduct gems
            userProgress.totalGems -= storybook.requiredGems

            // Unlock storybook
            storybook.isUnlocked = true

            // Save changes
            do {
                try modelContext.save()
                print("📚 Unlocked storybook: \(storybook.title)")
            } catch {
                print("❌ Failed to save storybook unlock: \(error)")
            }
        } else {
            insufficientGems = true
        }

        selectedStorybook = nil
    }
}

// MARK: - Storybook Card

struct StorybookCard: View {
    let storybook: Storybook
    let currentGems: Int
    let onUnlock: () -> Void

    var body: some View {
        NavigationLink(destination: destinationView) {
            HStack(spacing: 16) {
                // Cover Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(storybook.isUnlocked ? Color.purple.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 80, height: 100)

                    if storybook.isUnlocked {
                        Image(systemName: "book.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.purple)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.gray)
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(storybook.title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(storybook.pages.count) pages")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Status
                    if storybook.isUnlocked {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("storybooks.status.unlocked".localized)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    } else {
                        HStack(spacing: 4) {
                            Text("💎")
                                .font(.caption)
                            Text("\(storybook.requiredGems)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(currentGems >= storybook.requiredGems ? .cyan : .red)
                            Text("storybooks.to.unlock".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                if !storybook.isUnlocked {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .disabled(!storybook.isUnlocked)
        .simultaneousGesture(
            TapGesture().onEnded {
                if !storybook.isUnlocked {
                    onUnlock()
                }
            }
        )
    }

    @ViewBuilder
    private var destinationView: some View {
        if storybook.isUnlocked {
            StorybookReaderView(storybook: storybook)
        } else {
            EmptyView()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StorybooksListView()
            .modelContainer(for: [Storybook.self, StoryPage.self, UserProgress.self], inMemory: true)
    }
}
