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
    @State private var showResetConfirmation = false

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

                    Button("settings.data.reset".localized, role: .destructive) {
                        showResetConfirmation = true
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    EmptyView()
                }
            }
            .alert("settings.data.reset.confirm.title".localized, isPresented: $showResetConfirmation) {
                Button("common.cancel".localized, role: .cancel) { }
                Button("settings.data.reset.confirm".localized, role: .destructive) {
                    resetUserData()
                }
            } message: {
                Text("settings.data.reset.confirm.message".localized)
            }
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

    private func resetUserData() {
        do {
            // 1. Reset user progress (stars, gems, streak)
            let progressDescriptor = FetchDescriptor<UserProgress>()
            let userProgresses = try modelContext.fetch(progressDescriptor)
            for progress in userProgresses {
                progress.totalStars = 0
                progress.totalGems = 5  // Reset to initial value
                progress.currentStreak = 0
                progress.lastStudyDate = nil
                progress.lastMasteredMilestone = 0
            }

            // 2. Delete all practice records
            let practiceDescriptor = FetchDescriptor<PracticeRecord>()
            let practiceRecords = try modelContext.fetch(practiceDescriptor)
            for record in practiceRecords {
                modelContext.delete(record)
            }

            // 3. Delete all word progress
            let wordProgressDescriptor = FetchDescriptor<WordProgress>()
            let wordProgresses = try modelContext.fetch(wordProgressDescriptor)
            for wordProgress in wordProgresses {
                modelContext.delete(wordProgress)
            }

            // 4. Delete all test records
            let testDescriptor = FetchDescriptor<TestRecord>()
            let testRecords = try modelContext.fetch(testDescriptor)
            for testRecord in testRecords {
                modelContext.delete(testRecord)
            }

            // 5. Reset all achievements
            let achievementDescriptor = FetchDescriptor<Achievement>()
            let achievements = try modelContext.fetch(achievementDescriptor)
            for achievement in achievements {
                achievement.reset()
            }

            // 6. Reset all flashcard progress
            let flashcardDescriptor = FetchDescriptor<FlashcardProgress>()
            let flashcardProgresses = try modelContext.fetch(flashcardDescriptor)
            for flashcard in flashcardProgresses {
                modelContext.delete(flashcard)
            }

            // 7. Reset unit unlock status (keep only Unite 1)
            let uniteDescriptor = FetchDescriptor<Unite>()
            let unites = try modelContext.fetch(uniteDescriptor)
            for unite in unites {
                if unite.number == 1 {
                    unite.isUnlocked = true
                } else {
                    unite.isUnlocked = false
                }
            }

            // 8. Reset all game modes to locked
            let gameModeDescriptor = FetchDescriptor<GameMode>()
            let gameModes = try modelContext.fetch(gameModeDescriptor)
            for gameMode in gameModes {
                gameMode.isUnlocked = false
            }

            // 9. Reset all storybooks to locked
            let storybookDescriptor = FetchDescriptor<Storybook>()
            let storybooks = try modelContext.fetch(storybookDescriptor)
            for storybook in storybooks {
                storybook.isUnlocked = false
            }

            try modelContext.save()

            print("✅ All user data reset completed")
            print("   - Stars: 0")
            print("   - Gems: 5")
            print("   - Streak: 0")
            print("   - Practice records: deleted")
            print("   - Word progress: deleted")
            print("   - Test records: deleted")
            print("   - Achievements: reset")
            print("   - Flashcards: reset")
            print("   - Units: only Unite 1 unlocked")
            print("   - Games: all locked")
            print("   - Storybooks: all locked")
        } catch {
            print("❌ User data reset failed: \(error)")
        }
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