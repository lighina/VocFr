//
//  UniteView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct UnitsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unites: [Unite]
    @State private var viewModel = UnitsViewModel()
    @State private var showImportAlert = false
    @State private var selectedUnite: Unite?
    @State private var showUnlockDialog = false
    @State private var insufficientGems = false

    var body: some View {
        List {
            // Stars progress section (Part B.1)
            StarsProgressView()
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)

            // Units list
            ForEach(unites.sorted(by: { $0.number < $1.number })) { unite in
                if unite.isUnlocked {
                    NavigationLink(destination: UniteDetailView(unite: unite)) {
                        UniteRowView(unite: unite)
                    }
                } else {
                    Button(action: {
                        selectedUnite = unite
                        showUnlockDialog = true
                    }) {
                        UniteRowView(unite: unite)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(0.6)
                }
            }
        }
        .navigationTitle("units.title".localized)
        .toolbar {
            ToolbarItem {
                Button(action: importData) {
                    Label("units.import.button".localized, systemImage: viewModel.isImporting ? "arrow.down.circle" : "square.and.arrow.down")
                }
                .disabled(viewModel.isImporting)
            }
        }
        .onAppear {
            // Initialize ViewModel with ModelContext
            viewModel = UnitsViewModel(modelContext: modelContext)

            // Award daily login points (Part B.1)
            PointsManager.shared.awardDailyLoginPoints(modelContext: modelContext)
        }
        .alert("units.import.alert.title".localized, isPresented: $showImportAlert) {
            Button("units.import.alert.ok".localized) {
                viewModel.resetImportStatus()
            }
        } message: {
            if viewModel.importSucceeded {
                Text("units.import.success".localized)
            } else if let errorMessage = viewModel.errorMessage {
                Text("units.import.failed".localized(errorMessage))
            }
        }
        .alert("Unlock Unit", isPresented: $showUnlockDialog) {
            if let unite = selectedUnite {
                Button("Unlock with \(unite.requiredGems) 💎") {
                    unlockWithGems(unite)
                }
                Button("Cancel", role: .cancel) {}
            }
        } message: {
            if let unite = selectedUnite {
                Text("Unlock \(unite.title) with \(unite.requiredGems) gems?")
            }
        }
        .alert("Insufficient Gems", isPresented: $insufficientGems) {
            Button("OK") {}
        } message: {
            Text("You don't have enough gems to unlock this unit.")
        }
    }

    private func importData() {
        viewModel.importData()
        showImportAlert = true
    }

    private func unlockWithGems(_ unite: Unite) {
        // Get user progress
        let descriptor = FetchDescriptor<UserProgress>()
        guard let userProgress = try? modelContext.fetch(descriptor).first else {
            print("⚠️ UserProgress not found")
            return
        }

        // Check if user has enough gems
        if userProgress.totalGems >= unite.requiredGems {
            // Deduct gems
            userProgress.totalGems -= unite.requiredGems

            // Unlock unit
            unite.isUnlocked = true

            // Save changes
            do {
                try modelContext.save()
                print("✅ Unit unlocked with gems: \(unite.title)")

                // Check achievement for unit unlocks
                let unlockedCount = unites.filter { $0.isUnlocked }.count
                AchievementManager.shared.checkUnitUnlocked(unlockedCount: unlockedCount, context: modelContext)
            } catch {
                print("❌ Failed to save unit unlock: \(error)")
            }
        } else {
            insufficientGems = true
        }
    }
}

struct UniteRowView: View {
    let unite: Unite

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("units.unite.title".localized(unite.number, unite.title))
                    .font(.headline)
                Text("units.sections.count".localized(unite.sections.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                if unite.isUnlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    VStack(alignment: .trailing, spacing: 4) {
                        Image(systemName: "lock")
                            .foregroundColor(.orange)

                        // Stars or Gems unlock option
                        HStack(spacing: 4) {
                            Text("⭐ \(unite.requiredStars)")
                                .font(.caption2)
                                .foregroundColor(.orange)

                            if unite.requiredGems > 0 {
                                Text("or")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Text("💎 \(unite.requiredGems)")
                                    .font(.caption2)
                                    .foregroundColor(.cyan)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct UniteDetailView: View {
    let unite: Unite
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        List {
            ForEach(unite.sections.sorted(by: { $0.orderIndex < $1.orderIndex })) { section in
                NavigationLink(destination: SectionDetailView(section: section)) {
                    SectionRowView(section: section)
                }
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Only track horizontal swipes from left edge
                    if value.startLocation.x < 50 && value.translation.width > 0 {
                        dragOffset = value.translation.width
                    }
                }
                .onEnded { value in
                    // Swipe right to go back (threshold: 100 points)
                    if value.startLocation.x < 50 && value.translation.width > 100 {
                        dismiss()
                    }
                    dragOffset = 0
                }
        )
        .navigationTitle(unite.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: navigationCoordinator.popToRootTrigger) { _, _ in
            // Dismiss when popToRoot is triggered
            dismiss()
        }
    }
}

struct SectionRowView: View {
    let section: Section

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(section.name.capitalized)
                .font(.headline)
            Text("section.words.count".localized(section.sectionWords.count))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview("Units View") {
    UnitsView()
        .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                              AudioFile.self, AudioSegment.self, UserProgress.self,
                              WordProgress.self, PracticeRecord.self, SectionWord.self], inMemory: true)
}
