import SwiftUI
import SwiftData

@main
struct VocFrApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(createModelContainer())
        }
    }

    private func createModelContainer() -> ModelContainer {
        let schema = Schema([
            Unite.self,
            Section.self,
            Word.self,
            WordForm.self,
            SectionWord.self,
            AudioFile.self,
            AudioSegment.self,
            UserProgress.self,
            WordProgress.self,
            PracticeRecord.self,
            Achievement.self,
            FlashcardProgress.self,
            TestRecord.self,
            WrongAnswerRecord.self,
            GameMode.self,         // Gems system: Game unlock
            Storybook.self,        // Gems system: Storybook
            StoryPage.self,        // Gems system: Storybook pages
            Item.self              // Keep for compatibility
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        var container: ModelContainer

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // If container creation fails due to schema mismatch, delete old database and retry
            print("⚠️ Model container creation failed, attempting to reset database...")
            print("Error: \(error)")

            // Delete old database files
            let fileManager = FileManager.default
            if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let storeURL = appSupport.appendingPathComponent("default.store")
                try? fileManager.removeItem(at: storeURL)
                print("🗑️ Deleted old database at: \(storeURL.path)")
            }

            // Try again
            do {
                container = try ModelContainer(for: schema, configurations: [configuration])
                print("✅ Successfully created new model container")
            } catch {
                fatalError("模型容器创建失败: \(error)")
            }
        }

        do {
            // Check if data needs to be seeded
            let context = container.mainContext
            let descriptor = FetchDescriptor<Unite>()

            let existingUnites = try context.fetch(descriptor)
            if existingUnites.isEmpty {
                // First launch, seed data
                print("首次启动，开始导入数据...")
                try FrenchVocabularySeeder.seedAllData(to: context)
                FrenchVocabularySeeder.addAudioTimestamps(to: context)

                // Load game modes and storybooks
                print("加载游戏模式和故事书...")
                try? GameDataLoader.loadGameModesIntoContext(context)
                try? GameDataLoader.loadStorybooksIntoContext(context)

                print("✅ 数据导入完成")

                let issues = FrenchVocabularySeeder.validateData(from: context)
                if !issues.isEmpty {
                    print("数据验证发现问题:")
                    for issue in issues {
                        print("- \(issue)")
                    }
                }
            }

            // Initialize and sync achievements on every app launch
            AchievementManager.shared.initializeAchievements(in: context)
        } catch {
            print("❌ Failed to seed data: \(error)")
        }

        return container
    }
}