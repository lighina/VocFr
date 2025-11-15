import SwiftUI
import SwiftData

@main
struct VocFrApp: App {
    init() {
        // 诊断：检查 vocabulary.json 是否在 bundle 中
        print("\n" + String(repeating: "=", count: 60))
        print("🔍 检查 vocabulary.json Bundle 配置")
        print(String(repeating: "=", count: 60))

        if let jsonURL = Bundle.main.url(forResource: "vocabulary", withExtension: "json") {
            print("✅ vocabulary.json 找到了！")
            print("   路径：\(jsonURL.path)")
        } else {
            print("❌ vocabulary.json 未找到在 bundle 中")
            print("\n📦 尝试查找 bundle 中的所有 JSON 文件：")

            if let resourcePath = Bundle.main.resourcePath {
                let fileManager = FileManager.default
                var jsonFiles: [String] = []

                if let enumerator = fileManager.enumerator(atPath: resourcePath) {
                    while let file = enumerator.nextObject() as? String {
                        if file.hasSuffix(".json") {
                            jsonFiles.append(file)
                        }
                    }
                }

                if jsonFiles.isEmpty {
                    print("   ❌ Bundle 中没有任何 .json 文件")
                } else {
                    print("   找到 \(jsonFiles.count) 个 JSON 文件：")
                    for file in jsonFiles {
                        print("     - \(file)")
                    }
                }
            }
        }
        print(String(repeating: "=", count: 60) + "\n")
    }

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

                // 🔍 诊断：检查 Word 对象的 imageName
                print("\n" + String(repeating: "=", count: 60))
                print("🔍 诊断：检查单词的 imageName 属性")
                print(String(repeating: "=", count: 60))

                let wordDescriptor = FetchDescriptor<Word>()
                if let allWords = try? context.fetch(wordDescriptor) {
                    print("总共加载了 \(allWords.count) 个单词\n")

                    // 特别检查带重音的单词
                    let accentedWords = ["éponge", "école", "fenêtre", "garçon", "mère", "père", "frère", "grand-mère", "grand-père"]

                    print("检查带重音的关键单词:")
                    for canonical in accentedWords {
                        if let word = allWords.first(where: { $0.canonical == canonical }) {
                            print("✓ \(canonical)")
                            print("  - imageName: '\(word.imageName)'")
                            print("  - chinese: \(word.chinese)")
                        } else {
                            print("✗ \(canonical) - 未找到")
                        }
                    }
                }
                print(String(repeating: "=", count: 60) + "\n")

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

            return container
        } catch {
            fatalError("模型容器创建失败: \(error)")
        }
    }
}