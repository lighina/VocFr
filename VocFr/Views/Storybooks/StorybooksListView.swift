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
    @Query private var testRecords: [TestRecord]

    @State private var showUnlockAlert = false
    @State private var selectedStorybook: Storybook?
    @State private var insufficientGems = false
    @State private var showTestRequiredAlert = false
    @State private var expandedUnites: Set<String> = []

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

                // Storybooks grouped by Unite
                VStack(spacing: 16) {
                    if groupedStorybooks.isEmpty {
                        Text("storybooks.empty".localized)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(groupedStorybooks, id: \.uniteId) { group in
                            UniteStorybookGroup(
                                unite: group.unite,
                                storybooks: group.storybooks,
                                isExpanded: expandedUnites.contains(group.uniteId),
                                currentGems: currentGems,
                                onToggle: {
                                    if expandedUnites.contains(group.uniteId) {
                                        expandedUnites.remove(group.uniteId)
                                    } else {
                                        expandedUnites.insert(group.uniteId)
                                    }
                                },
                                onUnlock: { storybook in
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
        .alert("Test Required", isPresented: $showTestRequiredAlert) {
            Button("OK") {}
        } message: {
            if let storybook = selectedStorybook,
               let unite = unites.first(where: { $0.id == storybook.uniteId }) {
                Text("Complete the test for Unite \(unite.number) with a score of 60% or higher to unlock this storybook.")
            }
        }
        .onAppear {
            // Auto-unlock default storybooks if test passed
            autoUnlockDefaultStorybooks()
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

    /// Group storybooks by Unite
    private var groupedStorybooks: [(uniteId: String, unite: Unite, storybooks: [Storybook])] {
        // Get all unlocked unites
        let unlockedUnites = unites.filter { $0.isUnlocked }.sorted { $0.number < $1.number }

        return unlockedUnites.compactMap { unite in
            let booksForUnite = allStorybooks.filter { $0.uniteId == unite.id }
                .sorted { $0.orderIndex < $1.orderIndex }

            // Only include unite if it has storybooks
            guard !booksForUnite.isEmpty else { return nil }

            return (uniteId: unite.id, unite: unite, storybooks: booksForUnite)
        }
    }

    /// Check if unite test has been passed (score >= 60)
    private func hasPassedUniteTest(_ uniteId: String) -> Bool {
        // Find test records for this unite with score >= 60
        return testRecords.contains { record in
            record.uniteId == uniteId && record.score >= 60
        }
    }

    // MARK: - Methods

    /// Auto-unlock default storybooks when test is passed
    private func autoUnlockDefaultStorybooks() {
        for storybook in allStorybooks {
            // Only auto-unlock default storybooks that aren't already unlocked
            guard storybook.isDefault && !storybook.isUnlocked else { continue }

            // Check if the unite test has been passed
            if hasPassedUniteTest(storybook.uniteId) {
                storybook.isUnlocked = true
                print("📚 Auto-unlocked default storybook: \(storybook.title)")
            }
        }

        // Save changes
        try? modelContext.save()
    }

    private func attemptUnlock(_ storybook: Storybook) {
        // For default storybooks, check if test is passed first
        if storybook.isDefault && !hasPassedUniteTest(storybook.uniteId) {
            showTestRequiredAlert = true
            return
        }

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

// MARK: - Unite Storybook Group

struct UniteStorybookGroup: View {
    let unite: Unite
    let storybooks: [Storybook]
    let isExpanded: Bool
    let currentGems: Int
    let onToggle: () -> Void
    let onUnlock: (Storybook) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Unite header (tappable to expand/collapse)
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)

                    Text("Unite \(unite.number): \(unite.title)")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(unlockedCount) / \(storybooks.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)

            // Storybooks list (shown when expanded)
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(storybooks) { storybook in
                        StorybookCard(
                            storybook: storybook,
                            currentGems: currentGems,
                            onUnlock: {
                                onUnlock(storybook)
                            }
                        )
                        .padding(.leading, 16)
                    }
                }
            }
        }
    }

    private var unlockedCount: Int {
        storybooks.filter { $0.isUnlocked }.count
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
                    if let coverImageName = storybook.coverImageName, !coverImageName.isEmpty {
                        Image(coverImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .opacity(storybook.isUnlocked ? 1.0 : 0.5)

                        if !storybook.isUnlocked {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.5))
                                .frame(width: 80, height: 100)

                            Image(systemName: "lock.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.8), radius: 4)
                        }
                    } else {
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
