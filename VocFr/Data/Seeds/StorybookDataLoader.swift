//
//  StorybookDataLoader.swift
//  VocFr
//
//  Created by Claude on 17/11/2025.
//  Loads storybook data from JSON
//

import Foundation
import SwiftData

class StorybookDataLoader {

    // MARK: - Main Entry Point

    /// Load all storybooks from JSON file
    static func loadStorybookData() throws -> [Storybook] {
        guard let url = Bundle.main.url(forResource: "Storybooks", withExtension: "json") else {
            throw DataLoadError.fileNotFound("Storybooks.json not found in bundle")
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        let storybookData = try decoder.decode(StorybookJSONContainer.self, from: data)

        // Convert JSON data to SwiftData models
        var storybooks: [Storybook] = []

        for storybookJSON in storybookData.storybooks {
            let storybook = Storybook(
                id: storybookJSON.id,
                title: storybookJSON.title,
                titleInChinese: storybookJSON.titleInChinese,
                uniteId: storybookJSON.uniteId,
                isUnlocked: storybookJSON.isUnlocked,
                isDefault: storybookJSON.isDefault,
                requiredGems: storybookJSON.requiredGems,
                orderIndex: storybookJSON.orderIndex,
                coverImageName: storybookJSON.coverImageName
            )

            // Create pages
            for pageJSON in storybookJSON.pages {
                let page = StoryPage(
                    pageNumber: pageJSON.pageNumber,
                    contentFrench: pageJSON.contentFrench,
                    contentChinese: pageJSON.contentChinese,
                    imageName: pageJSON.imageName,
                    audioFileName: pageJSON.audioFileName
                )
                page.storybook = storybook
                storybook.pages.append(page)
            }

            storybooks.append(storybook)
        }

        print("✅ Successfully loaded \(storybooks.count) storybooks from JSON")
        return storybooks
    }

    /// Seed storybooks to database (called during initial data import)
    static func seedStorybooks(to modelContext: ModelContext) throws {
        // Check if storybooks already exist
        let existingDescriptor = FetchDescriptor<Storybook>()
        let existingStorybooks = try modelContext.fetch(existingDescriptor)

        if !existingStorybooks.isEmpty {
            print("⚠️ Storybooks already imported. Found \(existingStorybooks.count) existing storybooks. Skipping import.")
            return
        }

        // Load and insert storybooks
        let storybooks = try loadStorybookData()

        for storybook in storybooks {
            modelContext.insert(storybook)
        }

        try modelContext.save()
        print("✅ Successfully seeded \(storybooks.count) storybooks to database")
    }
}

// MARK: - JSON Structures

private struct StorybookJSONContainer: Codable {
    let storybooks: [StorybookJSON]
}

private struct StorybookJSON: Codable {
    let id: String
    let title: String
    let titleInChinese: String
    let uniteId: String
    let isUnlocked: Bool
    let isDefault: Bool
    let requiredGems: Int
    let orderIndex: Int
    let coverImageName: String?
    let pages: [StoryPageJSON]
}

private struct StoryPageJSON: Codable {
    let pageNumber: Int
    let contentFrench: String
    let contentChinese: String
    let imageName: String?
    let audioFileName: String?
}

// MARK: - Error Types

enum DataLoadError: LocalizedError {
    case fileNotFound(String)
    case invalidData(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let message):
            return "File not found: \(message)"
        case .invalidData(let message):
            return "Invalid data: \(message)"
        }
    }
}
