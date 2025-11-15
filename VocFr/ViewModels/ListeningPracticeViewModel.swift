//
//  ListeningPracticeViewModel.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.1: Listening Mode
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel for Listening Practice session
/// Plays word audio and asks user to identify the correct word
@Observable
class ListeningPracticeViewModel {

    // MARK: - Dependencies

    let section: Section
    private let modelContext: ModelContext?

    // MARK: - State

    /// Current word index in the practice session
    private(set) var currentWordIndex: Int = 0

    /// Number of correct answers
    private(set) var correctCount: Int = 0

    /// Whether the practice session is completed
    private(set) var isCompleted: Bool = false

    /// Selected answer index (nil = not answered yet)
    private(set) var selectedAnswerIndex: Int? = nil

    /// Whether the selected answer is correct
    private(set) var isAnswerCorrect: Bool = false

    /// Shuffled options for current word (includes 1 correct + 3 distractors)
    private(set) var currentOptions: [Word] = []

    /// Points earned in this session
    private(set) var pointsEarned: Int = 0

    /// Number of times audio has been played for current word
    private(set) var playCount: Int = 0

    /// Maximum number of times audio can be played
    let maxPlayCount: Int = 3

    /// Has audio been auto-played for current word
    private var hasAutoPlayed: Bool = false

    // MARK: - Computed Properties

    /// Sorted words for this practice session
    var words: [Word] {
        section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }
    }

    /// Current word being practiced
    var currentWord: Word? {
        guard currentWordIndex < words.count else { return nil }
        return words[currentWordIndex]
    }

    /// Total word count
    var totalWords: Int {
        words.count
    }

    /// Progress text (e.g., "1 / 10")
    var progressText: String {
        "\(currentWordIndex + 1) / \(totalWords)"
    }

    /// Correct count text
    var correctCountText: String {
        "practice.correct.count".localized(correctCount)
    }

    /// Play count text (e.g., "1/3")
    var playCountText: String {
        "\(playCount)/\(maxPlayCount)"
    }

    /// Whether user can still play audio
    var canPlay: Bool {
        playCount < maxPlayCount
    }

    /// Accuracy percentage (0-100)
    var accuracyPercentage: Int {
        guard totalWords > 0 else { return 0 }
        return Int(Double(correctCount) / Double(totalWords) * 100)
    }

    /// Section name
    var sectionName: String {
        section.name
    }

    // MARK: - Initialization

    init(section: Section, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
        generateOptions()
    }

    // MARK: - Actions

    /// Called when audio playback is requested
    func incrementPlayCount() {
        if playCount < maxPlayCount {
            playCount += 1
        }
    }

    /// Mark that auto-play has occurred
    func markAutoPlayed() {
        hasAutoPlayed = true
    }

    /// Should auto-play audio (only once per word)
    func shouldAutoPlay() -> Bool {
        !hasAutoPlayed && playCount == 0
    }

    /// Select an answer
    func selectAnswer(at index: Int) {
        guard selectedAnswerIndex == nil else { return } // Already answered

        selectedAnswerIndex = index

        // Check if answer is correct
        let selectedWord = currentOptions[index]
        isAnswerCorrect = (selectedWord.id == currentWord?.id)

        if isAnswerCorrect {
            correctCount += 1
            // Award points based on play count
            let points = calculatePointsForAttempt()
            pointsEarned += points
        }

        // Auto advance after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextWord()
        }
    }

    /// Calculate points for current attempt based on play count
    private func calculatePointsForAttempt() -> Int {
        switch playCount {
        case 1:
            return 3 // First listen
        case 2:
            return 2 // Second listen
        case 3:
            return 1 // Third listen
        default:
            return 0
        }
    }

    /// Move to next word
    private func nextWord() {
        currentWordIndex += 1
        selectedAnswerIndex = nil
        isAnswerCorrect = false
        playCount = 0
        hasAutoPlayed = false

        if currentWordIndex >= totalWords {
            completeSession()
        } else {
            generateOptions()
        }
    }

    /// Generate 4 options (1 correct + 3 distractors) for current word
    private func generateOptions() {
        guard let correctWord = currentWord else {
            currentOptions = []
            return
        }

        // Get all other words as potential distractors
        var distractors = words.filter { $0.id != correctWord.id }

        // Shuffle and take 3 random distractors
        distractors.shuffle()
        let selectedDistractors = Array(distractors.prefix(3))

        // Combine correct word with distractors
        var options = selectedDistractors + [correctWord]

        // Shuffle options
        options.shuffle()

        currentOptions = options
    }

    /// Complete the practice session
    private func completeSession() {
        isCompleted = true
        savePracticeRecord()
    }

    /// Restart the practice session
    func restartPractice() {
        currentWordIndex = 0
        correctCount = 0
        isCompleted = false
        selectedAnswerIndex = nil
        isAnswerCorrect = false
        pointsEarned = 0
        playCount = 0
        hasAutoPlayed = false
        generateOptions()
    }

    // MARK: - Persistence

    /// Save practice record to database
    private func savePracticeRecord() {
        guard let modelContext = modelContext else {
            print("⚠️ ModelContext not available, skipping practice record save")
            return
        }

        let accuracy = Double(correctCount) / Double(totalWords)
        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Listening Practice",
            wordsStudied: totalWords,
            accuracy: accuracy,
            timeSpent: 0 // TODO: Implement time tracking
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            print("✅ Listening practice record saved: \(correctCount)/\(totalWords) correct, \(pointsEarned) stars earned")

            // Award points for completing practice
            if pointsEarned > 0 {
                PointsManager.shared.awardStars(points: pointsEarned, modelContext: modelContext, reason: "Listening practice completed")
            }

            // Track achievements
            trackAchievements(accuracy: accuracy, context: modelContext)

        } catch {
            print("❌ Failed to save listening practice record: \(error)")
        }
    }

    /// Track achievements for this practice session
    private func trackAchievements(accuracy: Double, context: ModelContext) {
        // Get practice count
        let descriptor = FetchDescriptor<PracticeRecord>()
        if let allRecords = try? context.fetch(descriptor) {
            AchievementManager.shared.checkPracticeCount(practiceCount: allRecords.count, context: context)
        }

        // Check for perfect practice
        if accuracy >= 1.0 {
            let perfectDescriptor = FetchDescriptor<PracticeRecord>(
                predicate: #Predicate { $0.accuracy >= 1.0 }
            )
            if let perfectRecords = try? context.fetch(perfectDescriptor) {
                let isPerfect20 = totalWords >= 20
                AchievementManager.shared.checkPerfectPractice(
                    perfectCount: perfectRecords.count,
                    isPerfect20: isPerfect20,
                    context: context
                )
            }
        }

        // Check special time-based achievements
        AchievementManager.shared.checkSpecialAchievements(context: context)

        // Check points achievements
        if let userProgress = try? context.fetch(FetchDescriptor<UserProgress>()).first {
            AchievementManager.shared.checkPoints(totalPoints: userProgress.totalStars, context: context)
        }
    }
}
