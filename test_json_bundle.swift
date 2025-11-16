// 测试脚本：验证 vocabulary.json 是否在 App Bundle 中
// 将此代码临时添加到 VocFrApp.swift 或任何 View 的 init() 或 onAppear 中

import Foundation
import SwiftUI

func testJSONBundle() {
    print("\n" + String(repeating: "=", count: 60))
    print("🔍 测试 vocabulary.json Bundle 配置")
    print(String(repeating: "=", count: 60))

    // 测试 1：检查文件是否在 bundle 中
    print("\n📦 测试 1：检查 Bundle.main.url()")
    if let jsonURL = Bundle.main.url(forResource: "vocabulary", withExtension: "json") {
        print("✅ vocabulary.json 找到了！")
        print("   路径：\(jsonURL.path)")

        // 检查文件大小
        if let attributes = try? FileManager.default.attributesOfItem(atPath: jsonURL.path),
           let fileSize = attributes[.size] as? Int {
            print("   文件大小：\(fileSize) bytes (\(fileSize / 1024) KB)")
        }
    } else {
        print("❌ vocabulary.json 未找到在 bundle 中")
    }

    // 测试 2：尝试带子目录的路径
    print("\n📦 测试 2：检查 Bundle.main.url(subdirectory)")
    if let jsonURL = Bundle.main.url(forResource: "vocabulary",
                                       withExtension: "json",
                                       subdirectory: "Data/JSON") {
        print("✅ vocabulary.json 找到了（带子目录）！")
        print("   路径：\(jsonURL.path)")
    } else {
        print("❌ vocabulary.json 未找到（带子目录路径）")
    }

    // 测试 3：列出 Bundle 中的所有 JSON 文件
    print("\n📦 测试 3：列出 Bundle 中所有 JSON 文件")
    if let resourcePath = Bundle.main.resourcePath {
        print("Bundle 资源路径：\(resourcePath)")
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
            print("❌ 未找到任何 .json 文件在 bundle 中")
        } else {
            print("✅ 找到 \(jsonFiles.count) 个 JSON 文件：")
            for file in jsonFiles {
                print("   - \(file)")
            }
        }
    }

    // 测试 4：尝试实际加载 JSON
    print("\n📖 测试 4：尝试加载和解析 JSON")
    do {
        let unites = try VocabularyDataLoader.loadVocabularyData()
        print("✅ JSON 加载成功！")
        print("   Unités: \(unites.count)")

        let totalSections = unites.reduce(0) { $0 + $1.sections.count }
        print("   Sections: \(totalSections)")

        var totalWords = 0
        for unite in unites {
            for section in unite.sections {
                totalWords += section.sectionWords.count
            }
        }
        print("   Words: \(totalWords)")

    } catch let error as VocabularyDataLoader.DataLoaderError {
        print("❌ JSON 加载失败：")
        switch error {
        case .fileNotFound(let message):
            print("   文件未找到：\(message)")
        case .decodingFailed(let message):
            print("   解码失败：\(message)")
        case .invalidData(let message):
            print("   数据无效：\(message)")
        }
    } catch {
        print("❌ 未知错误：\(error)")
    }

    // 测试 5：列出 Bundle 根目录的内容（前 30 个文件）
    print("\n📦 测试 5：Bundle 根目录内容（前 30 个）")
    if let resourcePath = Bundle.main.resourcePath {
        let fileManager = FileManager.default
        if let files = try? fileManager.contentsOfDirectory(atPath: resourcePath) {
            print("总文件数：\(files.count)")
            for file in files.prefix(30) {
                var isDirectory: ObjCBool = false
                let fullPath = (resourcePath as NSString).appendingPathComponent(file)
                fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory)
                let type = isDirectory.boolValue ? "📁" : "📄"
                print("   \(type) \(file)")
            }
            if files.count > 30 {
                print("   ... 还有 \(files.count - 30) 个文件/文件夹")
            }
        }
    }

    print("\n" + String(repeating: "=", count: 60))
    print("测试完成")
    print(String(repeating: "=", count: 60) + "\n")
}

// 使用方法 1：在 VocFrApp.swift 中
/*
@main
struct VocFrApp: App {
    init() {
        testJSONBundle()  // 添加这一行
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(...)
        }
    }
}
*/

// 使用方法 2：在任何 View 中
/*
struct ContentView: View {
    var body: some View {
        Text("Hello")
            .onAppear {
                testJSONBundle()  // 添加这一行
            }
    }
}
*/
