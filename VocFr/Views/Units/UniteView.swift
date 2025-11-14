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

    var body: some View {
        NavigationView {
            List {
                // Stars progress section (Part B.1)
                StarsProgressView()
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                // Units list
                ForEach(unites.sorted(by: { $0.number < $1.number })) { unite in
                    NavigationLink {
                        UniteDetailView(unite: unite)
                    } label: {
                        UniteRowView(unite: unite)
                    }
                    .disabled(!unite.isUnlocked)
                    .opacity(unite.isUnlocked ? 1.0 : 0.6)
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
        }
    }

    private func importData() {
        viewModel.importData()
        showImportAlert = true
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
                    VStack {
                        Image(systemName: "lock")
                            .foregroundColor(.orange)
                        Text("units.unlock.required".localized(unite.requiredStars))
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct UniteDetailView: View {
    let unite: Unite

    var body: some View {
        List {
            ForEach(unite.sections.sorted(by: { $0.orderIndex < $1.orderIndex })) { section in
                NavigationLink {
                    SectionDetailView(section: section)
                } label: {
                    SectionRowView(section: section)
                }
            }
        }
        .navigationTitle(unite.title)
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
