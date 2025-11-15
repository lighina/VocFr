//
//  UnitsViewModel.swift
//  VocFr
//
//  Created by Claude on 14/11/2025.
//  Phase 3.3: MVVM Architecture Refactoring
//

import Foundation
import SwiftData

/// ViewModel for Units List View
/// Manages data import and error handling
@Observable
class UnitsViewModel {

    // MARK: - Dependencies

    private let modelContext: ModelContext?

    // MARK: - State

    /// Import status
    enum ImportStatus {
        case idle
        case importing
        case success
        case failure(Error)
    }

    private(set) var importStatus: ImportStatus = .idle

    /// Error message for display
    var errorMessage: String? {
        if case .failure(let error) = importStatus {
            return error.localizedDescription
        }
        return nil
    }

    /// Whether import is in progress
    var isImporting: Bool {
        if case .importing = importStatus {
            return true
        }
        return false
    }

    /// Whether import was successful
    var importSucceeded: Bool {
        if case .success = importStatus {
            return true
        }
        return false
    }

    // MARK: - Initialization

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
    }

    // MARK: - Actions

    /// Import vocabulary data
    func importData() {
        guard let modelContext = modelContext else {
            importStatus = .failure(NSError(domain: "UnitsViewModel", code: -1,
                                           userInfo: [NSLocalizedDescriptionKey: "ModelContext 不可用"]))
            return
        }

        importStatus = .importing

        do {
            try FrenchVocabularySeeder.seedAllData(to: modelContext)
            importStatus = .success
        } catch {
            importStatus = .failure(error)
            print("❌ 数据导入失败: \(error)")
        }
    }

    /// Reset import status
    func resetImportStatus() {
        importStatus = .idle
    }
}
