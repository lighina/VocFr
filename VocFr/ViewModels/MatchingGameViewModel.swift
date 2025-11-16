//
//  MatchingGameViewModel.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.2: Matching Game Mode
//

import Foundation
import SwiftUI
import SwiftData

/// Card type for matching game
enum CardType {
    case image  // Shows word image
    case text   // Shows French word
}

/// Single card in the matching game
struct MatchingCard: Identifiable, Equatable {
    let id = UUID()
    let word: Word
    let type: CardType
    var isFaceUp: Bool = false
    var isMatched: Bool = false

    // Custom equality check (ignore mutable properties for comparison)
    static func == (lhs: MatchingCard, rhs: MatchingCard) -> Bool {
        lhs.id == rhs.id
    }

    /// Check if two cards form a matching pair
    func matches(_ other: MatchingCard) -> Bool {
        // Must be different types (image vs text) and same word
        guard self.type != other.type else { return false }
        return self.word.id == other.word.id
    }
}

/// ViewModel for Matching Game
@Observable
class MatchingGameViewModel {

    // MARK: - Dependencies

    let section: Section
    private let modelContext: ModelContext?

    // MARK: - State

    /// All cards in the game (6 words × 2 cards = 12 cards)
    var cards: [MatchingCard] = []

    /// Refresh trigger to force SwiftUI to re-render cards
    var refreshTrigger: UUID = UUID()

    /// Currently selected cards (max 2)
    private(set) var selectedCards: [MatchingCard] = []

    /// Number of matched pairs
    private(set) var matchedPairs: Int = 0

    /// Number of attempts (pairs tried)
    private(set) var attempts: Int = 0

    /// Elapsed time in seconds
    private(set) var elapsedTime: TimeInterval = 0

    /// Total score
    private(set) var score: Int = 0

    /// Whether the game is completed
    private(set) var isCompleted: Bool = false

    /// Timer for tracking game duration
    private var timer: Timer?

    /// Whether the game has started (first card clicked)
    private var hasStarted: Bool = false

    /// Number of pairs to match (will be set based on available words)
    private var pairCount: Int = 6

    /// Actual number of pairs in this game (may be less than pairCount if section has fewer words)
    private var actualPairCount: Int = 0

    // MARK: - Computed Properties

    /// Total number of pairs (actual pairs in this game)
    var totalPairs: Int {
        actualPairCount
    }

    /// Progress text (e.g., "2/6 pairs")
    var progressText: String {
        "\(matchedPairs)/\(totalPairs)"
    }

    /// Formatted elapsed time (mm:ss)
    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Whether user can select more cards
    var canSelectCard: Bool {
        selectedCards.count < 2
    }

    /// Section name
    var sectionName: String {
        section.name
    }

    // MARK: - Initialization

    init(section: Section, modelContext: ModelContext? = nil) {
        self.section = section
        self.modelContext = modelContext
        setupGame()
    }

    // MARK: - Game Setup

    /// Setup the game with shuffled cards
    private func setupGame() {
        // Get words from section
        let words = section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }

        // Take first 6 words (or all if less than 6)
        let selectedWords = Array(words.prefix(pairCount))

        // Set actual pair count based on selected words
        actualPairCount = selectedWords.count

        // Create pairs of cards (image + text) for each word
        var newCards: [MatchingCard] = []
        for word in selectedWords {
            newCards.append(MatchingCard(word: word, type: .image))
            newCards.append(MatchingCard(word: word, type: .text))
        }

        // Shuffle cards
        newCards.shuffle()

        cards = newCards

        // Don't start timer yet - wait for first card click

        print("🎮 Game setup: \(actualPairCount) pairs to match")
    }

    // MARK: - Timer Management

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isCompleted else { return }
            self.elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Game Actions

    /// Select a card
    func selectCard(_ card: MatchingCard) {
        print("🎮 Card tapped: \(card.word.canonical) (\(card.type))")

        // Start timer on first card click
        if !hasStarted {
            hasStarted = true
            startTimer()
            print("⏱️ Timer started")
        }

        // Find card index
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else {
            print("❌ Card not found in array")
            return
        }

        // Ignore if card is already face up or matched
        guard !cards[index].isFaceUp && !cards[index].isMatched else {
            print("⚠️ Card already face up or matched")
            return
        }

        // Ignore if already selected 2 cards
        guard selectedCards.count < 2 else {
            print("⚠️ Already have 2 cards selected")
            return
        }

        print("✅ Flipping card at index \(index)")

        // Create a new array to trigger SwiftUI update
        var newCards = cards
        newCards[index].isFaceUp = true
        cards = newCards
        refreshTrigger = UUID()  // Force UI refresh

        selectedCards.append(cards[index])

        print("📊 Selected cards: \(selectedCards.count)")
        print("📋 Card state after flip - isFaceUp: \(cards[index].isFaceUp)")

        // Check for match if 2 cards are selected
        if selectedCards.count == 2 {
            attempts += 1
            checkForMatch()
        }
    }

    /// Check if selected cards match
    private func checkForMatch() {
        guard selectedCards.count == 2 else { return }

        let card1 = selectedCards[0]
        let card2 = selectedCards[1]

        if card1.matches(card2) {
            // Match found!
            markCardsAsMatched(card1, card2)
            matchedPairs += 1

            // Award points
            let points = calculatePointsForMatch()
            score += points

            // Play correct match sound
            SoundEffectManager.shared.playCorrectSound()

            // Clear selection immediately
            selectedCards.removeAll()

            // Check if game is complete
            if matchedPairs == totalPairs {
                completeGame()
            }
        } else {
            // No match - flip cards back after delay
            // Play incorrect match sound
            SoundEffectManager.shared.playIncorrectSound()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipCardsBack(card1, card2)
                self.selectedCards.removeAll()
            }
        }
    }

    /// Mark cards as matched
    private func markCardsAsMatched(_ card1: MatchingCard, _ card2: MatchingCard) {
        var newCards = cards
        if let index1 = newCards.firstIndex(where: { $0.id == card1.id }) {
            newCards[index1].isMatched = true
        }
        if let index2 = newCards.firstIndex(where: { $0.id == card2.id }) {
            newCards[index2].isMatched = true
        }
        cards = newCards
        refreshTrigger = UUID()  // Force UI refresh

        print("✨ Marked cards as matched - UI should update now")
    }

    /// Flip cards back face down
    private func flipCardsBack(_ card1: MatchingCard, _ card2: MatchingCard) {
        var newCards = cards
        if let index1 = newCards.firstIndex(where: { $0.id == card1.id }) {
            newCards[index1].isFaceUp = false
        }
        if let index2 = newCards.firstIndex(where: { $0.id == card2.id }) {
            newCards[index2].isFaceUp = false
        }
        cards = newCards
        refreshTrigger = UUID()  // Force UI refresh

        print("🔄 Flipped cards back - UI should update now")
    }

    /// Calculate points for a successful match based on attempts
    private func calculatePointsForMatch() -> Int {
        // Base points for each match
        let basePoints = 10

        // Bonus for early matches (fewer attempts)
        let attemptBonus = max(0, 10 - attempts)

        return basePoints + attemptBonus
    }

    /// Complete the game
    private func completeGame() {
        isCompleted = true
        stopTimer()

        // Add time bonus
        let timeBonus = calculateTimeBonus()
        score += timeBonus

        savePracticeRecord()
    }

    /// Calculate time bonus based on completion time
    private func calculateTimeBonus() -> Int {
        if elapsedTime <= 60 {
            return 20 // Completed in 1 minute
        } else if elapsedTime <= 120 {
            return 10 // Completed in 2 minutes
        } else if elapsedTime <= 180 {
            return 5 // Completed in 3 minutes
        }
        return 0
    }

    /// Restart the game
    func restartGame() {
        selectedCards.removeAll()
        matchedPairs = 0
        attempts = 0
        elapsedTime = 0
        score = 0
        isCompleted = false
        hasStarted = false
        stopTimer()
        setupGame()
    }

    // MARK: - Persistence

    /// Save practice record to database
    private func savePracticeRecord() {
        guard let modelContext = modelContext else {
            print("⚠️ ModelContext not available, skipping practice record save")
            return
        }

        let accuracy = Double(matchedPairs) / Double(totalPairs)
        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Matching Game",
            wordsStudied: actualPairCount,
            accuracy: accuracy,
            timeSpent: elapsedTime
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            print("✅ Matching game record saved: \(matchedPairs)/\(totalPairs) pairs, \(score) points")

            // Award points
            if score > 0 {
                PointsManager.shared.awardStars(points: score, modelContext: modelContext, reason: "Matching game completed")
            }

            // Track achievements
            trackAchievements(accuracy: accuracy, context: modelContext)

        } catch {
            print("❌ Failed to save matching game record: \(error)")
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
                let isPerfect20 = actualPairCount >= 20
                AchievementManager.shared.checkPerfectPractice(
                    perfectCount: perfectRecords.count,
                    isPerfect20: isPerfect20,
                    context: context
                )
            }
        }

        // Check speed run achievement (under 60 seconds with 100% accuracy)
        AchievementManager.shared.checkSpeedRun(timeSpent: elapsedTime, accuracy: accuracy, context: context)

        // Check special time-based achievements
        AchievementManager.shared.checkSpecialAchievements(context: context)

        // Check points achievements
        if let userProgress = try? context.fetch(FetchDescriptor<UserProgress>()).first {
            AchievementManager.shared.checkPoints(totalPoints: userProgress.totalStars, context: context)
        }
    }

    deinit {
        stopTimer()
    }
}
