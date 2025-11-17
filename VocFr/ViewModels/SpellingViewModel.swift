//
//  SpellingViewModel.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.3: Spelling Mode - State Management
//

import Foundation
import SwiftUI
import SwiftData

/// Spelling result types
enum SpellingResult: Equatable {
    case correct
    case correctWithCase // Correct but wrong case
    case missingAccents // Missing accent marks
    case wrongAccents // Has accents but wrong ones
    case closeMatch(Int) // Close with N character differences
    case incorrect
}

/// ViewModel for Spelling Practice
@Observable
class SpellingViewModel {

    // MARK: - Dependencies

    let section: Section
    private var modelContext: ModelContext?

    // MARK: - State

    /// All words in practice queue
    private(set) var practiceQueue: [Word] = []

    /// Current word index
    private(set) var currentIndex: Int = 0

    /// User's current input
    var userInput: String = ""

    /// Current hint level (0-4)
    private(set) var hintLevel: Int = 0

    /// Whether answer has been submitted
    private(set) var hasSubmitted: Bool = false

    /// Last spelling result
    private(set) var lastResult: SpellingResult?

    /// Total words practiced
    private(set) var totalPracticed: Int = 0

    /// Correct answers
    private(set) var correctCount: Int = 0

    /// Practice completed
    private(set) var isCompleted: Bool = false

    // MARK: - Computed Properties

    /// Current word being practiced
    var currentWord: Word? {
        guard currentIndex < practiceQueue.count else { return nil }
        return practiceQueue[currentIndex]
    }

    /// Progress text
    var progressText: String {
        "\(currentIndex + 1)/\(practiceQueue.count)"
    }

    /// Progress percentage
    var progressPercentage: Double {
        guard practiceQueue.count > 0 else { return 0.0 }
        return Double(currentIndex) / Double(practiceQueue.count)
    }

    /// Accuracy rate
    var accuracy: Double {
        guard totalPracticed > 0 else { return 0.0 }
        return Double(correctCount) / Double(totalPracticed)
    }

    /// Section name
    var sectionName: String {
        section.name
    }

    /// Hint text based on current level
    var hintText: String {
        guard let word = currentWord else { return "" }
        let canonical = word.canonical.lowercased()

        switch hintLevel {
        case 0:
            // No hint
            return ""
        case 1:
            // Show word length with first letter
            let length = canonical.count
            let first = canonical.first ?? "_"
            let underscores = String(repeating: " _", count: max(0, length - 1))
            return "\(first)\(underscores)"
        case 2:
            // Show first 2 letters
            let prefix = canonical.prefix(min(2, canonical.count))
            let remaining = max(0, canonical.count - 2)
            let underscores = String(repeating: " _", count: remaining)
            return "\(prefix)\(underscores)"
        case 3:
            // Show vowels
            var result = ""
            for char in canonical {
                if "aeiouàâäéèêëïîôùûü".contains(char) {
                    result += "\(char) "
                } else {
                    result += "_ "
                }
            }
            return result.trimmingCharacters(in: .whitespaces)
        case 4:
            // Show complete word
            return canonical
        default:
            return ""
        }
    }

    // MARK: - Initialization

    init(section: Section, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
        loadPracticeQueue()
    }

    /// Set or update model context
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        if practiceQueue.isEmpty {
            loadPracticeQueue()
        }
    }

    // MARK: - Queue Management

    private func loadPracticeQueue() {
        practiceQueue = section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }

        print("📝 Loaded \(practiceQueue.count) words for spelling practice")

        if practiceQueue.isEmpty {
            isCompleted = true
        }
    }

    // MARK: - Spelling Check

    /// Check user's spelling
    func checkSpelling() -> SpellingResult {
        guard let word = currentWord else { return .incorrect }

        let correct = word.canonical.lowercased()
        let input = userInput.trimmingCharacters(in: .whitespaces).lowercased()

        // 1. Exact match
        if input == correct {
            return .correct
        }

        // 2. Case difference only
        if input.lowercased() == correct.lowercased() {
            return .correctWithCase
        }

        // 3. Check for accent issues
        let inputNormalized = input.folding(options: .diacriticInsensitive, locale: .current)
        let correctNormalized = correct.folding(options: .diacriticInsensitive, locale: .current)

        if inputNormalized == correctNormalized {
            // Base characters match, so it's an accent issue
            // Check if correct word has accents
            let correctHasAccents = correct != correctNormalized
            let inputHasAccents = input != inputNormalized

            if correctHasAccents && !inputHasAccents {
                // Correct word has accents, user didn't add them
                return .missingAccents
            } else if !correctHasAccents && inputHasAccents {
                // Correct word has no accents, user added them
                return .wrongAccents
            } else {
                // Both have accents but different ones
                return .wrongAccents
            }
        }

        // 4. Close match (Levenshtein distance)
        let distance = levenshteinDistance(input, correct)
        if distance <= 2 {
            return .closeMatch(distance)
        }

        return .incorrect
    }

    /// Submit answer and check spelling
    func submitAnswer() {
        guard !hasSubmitted, let word = currentWord else { return }

        hasSubmitted = true
        lastResult = checkSpelling()
        totalPracticed += 1

        // Play sound based on result
        switch lastResult {
        case .correct, .correctWithCase:
            SoundEffectManager.shared.playCorrectSound()
        case .missingAccents:
            SoundEffectManager.shared.playNeutralSound()
        case .wrongAccents, .closeMatch, .incorrect:
            SoundEffectManager.shared.playIncorrectSound()
        case .none:
            break
        }

        // Award points based on hint level and result
        if case .correct = lastResult {
            correctCount += 1
            awardPoints()
        } else if case .correctWithCase = lastResult {
            correctCount += 1
            awardPoints()
        } else if case .missingAccents = lastResult {
            // Partial credit for missing accents
            awardPoints(multiplier: 0.5)
        } else if case .wrongAccents = lastResult {
            // No credit for wrong accents (more serious error)
            // Don't count as correct
        }

        print("📝 Spelling check: \(userInput) vs \(word.canonical) - Result: \(lastResult!)")
    }

    /// Award points based on hint level
    private func awardPoints(multiplier: Double = 1.0) {
        guard let modelContext = modelContext else { return }

        let basePoints: Int
        switch hintLevel {
        case 0: basePoints = 5  // No hints
        case 1: basePoints = 3  // 1 hint
        case 2: basePoints = 2  // 2 hints
        case 3: basePoints = 1  // 3 hints
        default: basePoints = 0 // Complete word shown
        }

        let points = Int(Double(basePoints) * multiplier)
        if points > 0 {
            PointsManager.shared.awardStars(
                points: points,
                modelContext: modelContext,
                reason: "Spelling practice"
            )
        }
    }

    /// Request a hint
    func requestHint() {
        if hintLevel < 4 {
            hintLevel += 1
        }
    }

    /// Move to next word
    func nextWord() {
        // Reset state
        userInput = ""
        hintLevel = 0
        hasSubmitted = false
        lastResult = nil

        // Move to next
        currentIndex += 1

        // Check completion
        if currentIndex >= practiceQueue.count {
            completeSession()
        }
    }

    /// Complete the practice session
    private func completeSession() {
        isCompleted = true
        savePracticeRecord()
        trackAchievements()
        print("✅ Spelling practice completed: \(totalPracticed) words, \(correctCount) correct")
    }

    /// Restart practice
    func restart() {
        currentIndex = 0
        userInput = ""
        hintLevel = 0
        hasSubmitted = false
        lastResult = nil
        totalPracticed = 0
        correctCount = 0
        isCompleted = false
        loadPracticeQueue()
    }

    // MARK: - Persistence

    private func savePracticeRecord() {
        guard let modelContext = modelContext, totalPracticed > 0 else { return }

        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Spelling Practice",
            wordsStudied: totalPracticed,
            accuracy: accuracy,
            timeSpent: 0
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            print("✅ Spelling practice session saved")
        } catch {
            print("❌ Failed to save spelling session: \(error)")
        }
    }

    private func trackAchievements() {
        guard let modelContext = modelContext else { return }

        // Track practice count
        let descriptor = FetchDescriptor<PracticeRecord>()
        if let allRecords = try? modelContext.fetch(descriptor) {
            AchievementManager.shared.checkPracticeCount(
                practiceCount: allRecords.count,
                context: modelContext
            )
        }

        // Check for perfect practice
        if accuracy >= 1.0 && totalPracticed >= 5 {
            let perfectDescriptor = FetchDescriptor<PracticeRecord>(
                predicate: #Predicate { $0.accuracy >= 1.0 }
            )
            if let perfectRecords = try? modelContext.fetch(perfectDescriptor) {
                AchievementManager.shared.checkPerfectPractice(
                    perfectCount: perfectRecords.count,
                    isPerfect20: totalPracticed >= 20,
                    context: modelContext
                )
            }
        }

        // Check special time-based achievements
        AchievementManager.shared.checkSpecialAchievements(context: modelContext)

        // Check learning milestones
        let wordProgressDescriptor = FetchDescriptor<WordProgress>(
            predicate: #Predicate { $0.lastReviewed != nil }
        )
        if let wordProgresses = try? modelContext.fetch(wordProgressDescriptor) {
            AchievementManager.shared.checkLearningMilestones(
                wordCount: wordProgresses.count,
                context: modelContext
            )
        }
    }

    // MARK: - Levenshtein Distance Algorithm

    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1Array = Array(s1)
        let s2Array = Array(s2)
        let m = s1Array.count
        let n = s2Array.count

        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m {
            matrix[i][0] = i
        }

        for j in 0...n {
            matrix[0][j] = j
        }

        for i in 1...m {
            for j in 1...n {
                let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,      // deletion
                    matrix[i][j - 1] + 1,      // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                )
            }
        }

        return matrix[m][n]
    }
}
