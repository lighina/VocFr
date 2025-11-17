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
    @Query(sort: \Storybook.orderIndex) private var storybooks: [Storybook]
    @Query private var userProgress: [UserProgress]

    @State private var showUnlockAlert = false
    @State private var selectedStorybook: Storybook?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "book.vertical.fill")
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
                    ForEach(storybooks) { storybook in
                        StorybookCard(
                            storybook: storybook,
                            currentGems: currentGems,
                            onUnlock: {
                                selectedStorybook = storybook
                                showUnlockAlert = true
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("storybooks.navigation.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("storybooks.unlock.title".localized, isPresented: $showUnlockAlert) {
            Button("storybooks.unlock.cancel".localized, role: .cancel) {
                selectedStorybook = nil
            }
            Button("storybooks.unlock.confirm".localized) {
                if let storybook = selectedStorybook {
                    unlockStorybook(storybook)
                }
            }
        } message: {
            if let storybook = selectedStorybook {
                Text(String(format: "storybooks.unlock.message".localized, storybook.title, storybook.requiredGems))
            }
        }
    }

    // MARK: - Computed Properties

    private var currentGems: Int {
        userProgress.first?.totalGems ?? 0
    }

    // MARK: - Methods

    private func unlockStorybook(_ storybook: Storybook) {
        let success = PointsManager.shared.unlockStorybook(storybook, modelContext: modelContext)

        if success {
            print("📚 Unlocked storybook: \(storybook.title)")
        } else {
            print("❌ Failed to unlock storybook: Not enough gems")
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text(storybook.title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(storybook.titleInChinese)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

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
