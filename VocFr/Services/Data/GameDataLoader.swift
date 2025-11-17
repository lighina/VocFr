//
//  GameDataLoader.swift
//  VocFr
//
//  Created by Claude on 17/11/2025.
//  Loads game modes and storybooks from JSON files
//

import Foundation
import SwiftData

/// Loads game and storybook data from JSON files
class GameDataLoader {

    // MARK: - JSON Structures

    private struct GameModeJSON: Codable {
        let id: String
        let name: String
        let nameInChinese: String
        let descriptionText: String
        let isUnlocked: Bool
        let requiredGems: Int
        let orderIndex: Int
        let iconName: String
    }

    private struct StorybookJSON: Codable {
        let id: String
        let title: String
        let titleInChinese: String
        let uniteId: String
        let isUnlocked: Bool
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

    enum LoaderError: Error {
        case fileNotFound(String)
        case invalidJSON(String)
        case decodingFailed(Error)
    }

    // MARK: - Public Methods

    /// Load game modes from GameModes.json
    static func loadGameModes() throws -> [GameMode] {
        guard let url = findFile(name: "GameModes", extension: "json") else {
            throw LoaderError.fileNotFound("GameModes.json not found")
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jsonGameModes = try decoder.decode([GameModeJSON].self, from: data)

        print("🎮 Loaded \(jsonGameModes.count) game modes")

        return jsonGameModes.map { json in
            GameMode(
                id: json.id,
                name: json.name,
                nameInChinese: json.nameInChinese,
                descriptionText: json.descriptionText,
                isUnlocked: json.isUnlocked,
                requiredGems: json.requiredGems,
                orderIndex: json.orderIndex,
                iconName: json.iconName
            )
        }
    }

    /// Load storybooks from Storybooks.json
    static func loadStorybooks() throws -> [Storybook] {
        guard let url = findFile(name: "Storybooks", extension: "json") else {
            throw LoaderError.fileNotFound("Storybooks.json not found")
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jsonStorybooks = try decoder.decode([StorybookJSON].self, from: data)

        print("📚 Loaded \(jsonStorybooks.count) storybooks")

        return jsonStorybooks.map { json in
            let storybook = Storybook(
                id: json.id,
                title: json.title,
                titleInChinese: json.titleInChinese,
                uniteId: json.uniteId,
                isUnlocked: json.isUnlocked,
                requiredGems: json.requiredGems,
                orderIndex: json.orderIndex,
                coverImageName: json.coverImageName
            )

            // Add pages
            let pages = json.pages.map { pageJSON in
                StoryPage(
                    pageNumber: pageJSON.pageNumber,
                    contentFrench: pageJSON.contentFrench,
                    contentChinese: pageJSON.contentChinese,
                    imageName: pageJSON.imageName,
                    audioFileName: pageJSON.audioFileName
                )
            }

            storybook.pages = pages

            return storybook
        }
    }

    /// Load game modes into ModelContext
    static func loadGameModesIntoContext(_ context: ModelContext) throws {
        let gameModes = try loadGameModes()

        for gameMode in gameModes {
            context.insert(gameMode)
        }

        try context.save()
        print("✅ Game modes loaded into context")
    }

    /// Load storybooks into ModelContext
    static func loadStorybooksIntoContext(_ context: ModelContext) throws {
        let storybooks = try loadStorybooks()

        for storybook in storybooks {
            context.insert(storybook)

            // Pages are automatically inserted due to relationship
            for page in storybook.pages {
                page.storybook = storybook
            }
        }

        try context.save()
        print("✅ Storybooks loaded into context")
    }

    // MARK: - Helper Methods

    private static func findFile(name: String, extension ext: String) -> URL? {
        // Search in main bundle
        if let url = Bundle.main.url(forResource: name, withExtension: ext) {
            return url
        }

        // Search in Data/JSON directory
        if let url = Bundle.main.url(forResource: name, withExtension: ext, subdirectory: "Data/JSON") {
            return url
        }

        print("⚠️  File not found: \(name).\(ext)")
        return nil
    }
}
