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
            Item.self // Keep for compatibility
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            // Check if data needs to be seeded
            let context = container.mainContext
            let descriptor = FetchDescriptor<Unite>()
            
            let existingUnites = try context.fetch(descriptor)
            if existingUnites.isEmpty {
                // First launch, seed data
                print("首次启动，开始导入数据...")
                try FrenchVocabularySeeder.seedAllData(to: context)
                FrenchVocabularySeeder.addAudioTimestamps(to: context)
                
                print("数据导入完成")
                print(FrenchVocabularySeeder.generateDataReport(from: context))
                
                let issues = FrenchVocabularySeeder.validateData(from: context)
                if !issues.isEmpty {
                    print("数据验证发现问题:")
                    for issue in issues {
                        print("- \(issue)")
                    }
                }
            }
            
            return container
        } catch {
            fatalError("模型容器创建失败: \(error)")
        }
    }
}