//
//  SettingsView.swift
//  VocFr
//
//  Created by Junfeng Wang on 22/09/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var languageManager = LanguageManager.shared

    var body: some View {
        NavigationView {
            List {
                // Language selection section
                SwiftUI.Section {
                    Picker("settings.language.title".localized, selection: $languageManager.currentLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    }
                } header: {
                    Text("settings.language.title".localized)
                } footer: {
                    Text("settings.language.description".localized)
                }

                // Data management section
                SwiftUI.Section("settings.data.title".localized) {
                    Button("settings.data.reimport".localized) {
                        reimportData()
                    }

                    Button("settings.data.export".localized) {
                        exportReport()
                    }

                    Button("settings.data.reset.stars".localized, role: .destructive) {
                        resetStars()
                    }
                }

                // About section
                SwiftUI.Section("settings.about.title".localized) {
                    HStack {
                        Text("settings.about.version".localized)
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("settings.title".localized)
        }
    }
    
    private func reimportData() {
        // Clear existing data first
        do {
            let uniteDescriptor = FetchDescriptor<Unite>()
            let existingUnites = try modelContext.fetch(uniteDescriptor)
            for unite in existingUnites {
                modelContext.delete(unite)
            }
            
            try modelContext.save()
            
            // Reimport
            try FrenchVocabularySeeder.seedAllData(to: modelContext)
            FrenchVocabularySeeder.addAudioTimestamps(to: modelContext)
            
            print("✅ Data reimport completed")
        } catch {
            print("❌ Data reimport failed: \(error)")
        }
    }
    
    private func exportReport() {
        let report = FrenchVocabularySeeder.generateDataReport(from: modelContext)
        print(report)
        // TODO: Share report via share sheet
    }

    private func resetStars() {
        PointsManager.shared.resetAllStars(modelContext: modelContext)
        print("✅ Stars reset completed")
    }
}

struct SettingsPreview: View {
    var body: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, WordForm.self,
                                           AudioFile.self, AudioSegment.self, UserProgress.self,
                                           WordProgress.self, PracticeRecord.self, SectionWord.self,
                                           configurations: config)
        
        return SettingsView()
            .modelContainer(container)
    }
}

#Preview {
    SettingsPreview()
}