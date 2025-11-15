// 临时诊断代码：检查 Word 对象的 imageName 属性
// 添加到 VocFrApp.swift 的 createModelContainer() 函数中，
// 在 seedAllData() 之后，validateData() 之前

// 诊断：检查加载的单词的 imageName
print("\n🔍 诊断：检查前10个单词的 imageName 属性")
print(String(repeating: "=", count: 60))

let wordDescriptor = FetchDescriptor<Word>()
if let allWords = try? context.fetch(wordDescriptor) {
    print("总共加载了 \(allWords.count) 个单词")

    // 特别检查带重音的单词
    let accentedWords = ["éponge", "école", "fenêtre", "garçon", "mère", "père", "frère", "grand-mère", "grand-père", "écouter", "zéro", "derrière"]

    print("\n检查带重音的关键单词:")
    for canonical in accentedWords {
        if let word = allWords.first(where: { $0.canonical == canonical }) {
            print("✓ \(canonical)")
            print("  - imageName: \(word.imageName)")
            print("  - chinese: \(word.chinese)")
        } else {
            print("✗ \(canonical) - 未找到")
        }
    }

    print("\n前10个单词的详细信息:")
    for (index, word) in allWords.prefix(10).enumerated() {
        print("\n[\(index + 1)] \(word.canonical)")
        print("  - ID: \(word.id)")
        print("  - imageName: \(word.imageName)")
        print("  - chinese: \(word.chinese)")
        print("  - category: \(word.category)")
    }
}

print(String(repeating: "=", count: 60) + "\n")
