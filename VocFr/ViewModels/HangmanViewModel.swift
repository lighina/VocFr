//
//  HangmanViewModel.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Hangman game logic for French word guessing
//

import Foundation
import SwiftUI
import SwiftData

/// ViewModel for Hangman word guessing game
@Observable
class HangmanViewModel {

    // MARK: - Dependencies

    let unite: Unite
    private let modelContext: ModelContext?

    // MARK: - Game State

    /// Current word being guessed
    private(set) var currentWord: Word?

    /// Letters that have been guessed
    private(set) var guessedLetters: Set<Character> = []

    /// Number of incorrect guesses
    private(set) var incorrectGuesses: Int = 0

    /// Maximum allowed incorrect guesses
    let maxIncorrectGuesses: Int = 10

    /// Current word index in the section
    private(set) var currentWordIndex: Int = 0

    /// Number of words completed
    private(set) var wordsCompleted: Int = 0

    /// Number of words won
    private(set) var wordsWon: Int = 0

    /// Game state
    private(set) var gameState: GameState = .playing

    /// Total points earned
    private(set) var totalPoints: Int = 0

    /// Track if any word was completed perfectly (0 incorrect guesses)
    private(set) var hasPerfectWord: Bool = false

    enum GameState {
        case playing
        case won
        case lost
        case sessionCompleted
    }

    // MARK: - Computed Properties

    /// Randomized words for Hangman game
    /// Words are shuffled on first access to ensure random order each game
    private lazy var words: [Word] = {
        var allWords: [Word] = []
        for section in unite.sections {
            let sectionWords = section.sectionWords.compactMap { $0.word }
            allWords.append(contentsOf: sectionWords)
        }
        return allWords.shuffled()
    }()

    /// Total number of words
    var totalWords: Int {
        words.count
    }

    /// The word to guess (normalized - lowercase, no articles)
    var wordToGuess: String {
        guard let word = currentWord else { return "" }
        return normalizeWord(word.canonical)
    }

    /// Display string with guessed letters and blanks
    var displayString: String {
        wordToGuess.map { char in
            if char == " " {
                return "  " // Space between words
            } else if char == "-" || char == "'" {
                return String(char) // Show hyphens and apostrophes
            } else if guessedLetters.contains(char) {
                return String(char)
            } else {
                return "_"
            }
        }.joined(separator: " ")
    }

    /// Letters that can be guessed (French alphabet + special characters)
    let availableLetters: [Character] = [
        "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
        "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
        "à", "â", "é", "è", "ê", "ë", "î", "ï", "ô", "û", "ù", "ü", "ç", "œ"
    ]

    /// Remaining incorrect guesses
    var remainingGuesses: Int {
        max(0, maxIncorrectGuesses - incorrectGuesses)
    }

    /// Is the game over?
    var isGameOver: Bool {
        gameState == .won || gameState == .lost
    }

    /// Progress text
    var progressText: String {
        "\(currentWordIndex + 1) / \(totalWords)"
    }

    /// Win rate
    var winRate: Int {
        guard wordsCompleted > 0 else { return 0 }
        return Int(Double(wordsWon) / Double(wordsCompleted) * 100)
    }

    // MARK: - Initialization

    init(unite: Unite, modelContext: ModelContext? = nil) {
        self.unite = unite
        self.modelContext = modelContext
        startNewWord()
    }

    // MARK: - Game Actions

    /// Guess a letter
    func guessLetter(_ letter: Character) {
        guard gameState == .playing else { return }
        guard !guessedLetters.contains(letter) else { return }

        guessedLetters.insert(letter)

        // Check if letter is in the word
        if wordToGuess.contains(letter) {
            // Correct guess - play success sound
            SoundEffectManager.shared.playCorrectSound()

            // Check if word is complete
            if isWordComplete() {
                winWord()
            }
        } else {
            // Incorrect guess
            incorrectGuesses += 1
            SoundEffectManager.shared.playIncorrectSound()

            // Check if game is lost
            if incorrectGuesses >= maxIncorrectGuesses {
                loseWord()
            }
        }
    }

    /// Guess the whole word
    func guessWord(_ guess: String) {
        guard gameState == .playing else { return }

        let normalizedGuess = guess.lowercased().trimmingCharacters(in: .whitespaces)

        if normalizedGuess == wordToGuess {
            // Correct word guess - fill all letters
            for char in wordToGuess {
                guessedLetters.insert(char)
            }
            winWord()
        } else {
            // Incorrect word guess - counts as incorrect
            incorrectGuesses += 1
            SoundEffectManager.shared.playIncorrectSound()

            if incorrectGuesses >= maxIncorrectGuesses {
                loseWord()
            }
        }
    }

    /// Start next word
    func nextWord() {
        currentWordIndex += 1

        if currentWordIndex >= totalWords {
            completeSession()
        } else {
            startNewWord()
        }
    }

    /// Restart current word
    func restartWord() {
        guessedLetters.removeAll()
        incorrectGuesses = 0
        gameState = .playing
    }

    /// Restart entire session
    func restartSession() {
        currentWordIndex = 0
        wordsCompleted = 0
        wordsWon = 0
        totalPoints = 0
        hasPerfectWord = false
        startNewWord()
    }

    // MARK: - Private Helpers

    /// Check if the current word is completely guessed
    private func isWordComplete() -> Bool {
        for char in wordToGuess {
            if char != " " && char != "-" && char != "'" && !guessedLetters.contains(char) {
                return false
            }
        }
        return true
    }

    /// Handle word win
    private func winWord() {
        gameState = .won
        wordsCompleted += 1
        wordsWon += 1

        // Track if this word was completed perfectly
        if incorrectGuesses == 0 {
            hasPerfectWord = true
        }

        // Award points based on incorrect guesses
        let points = calculatePoints()
        totalPoints += points

        // Play celebration sound
        SoundEffectManager.shared.playCorrectSound()
    }

    /// Handle word loss
    private func loseWord() {
        gameState = .lost
        wordsCompleted += 1

        // Play failure sound
        SoundEffectManager.shared.playIncorrectSound()
    }

    /// Start a new word
    private func startNewWord() {
        guard currentWordIndex < totalWords else { return }

        currentWord = words[currentWordIndex]
        guessedLetters.removeAll()
        incorrectGuesses = 0
        gameState = .playing
    }

    /// Complete the game session
    private func completeSession() {
        gameState = .sessionCompleted
        savePracticeRecord()
    }

    /// Calculate points for winning a word
    private func calculatePoints() -> Int {
        // More points for fewer incorrect guesses
        switch incorrectGuesses {
        case 0:
            return 10 // Perfect
        case 1...2:
            return 7
        case 3...5:
            return 5
        case 6...7:
            return 3
        default:
            return 1
        }
    }

    /// Normalize a French word (remove articles, lowercase)
    private func normalizeWord(_ word: String) -> String {
        var normalized = word.lowercased()

        // Remove common French articles
        let articles = ["le ", "la ", "les ", "l'", "un ", "une ", "des "]
        for article in articles {
            if normalized.hasPrefix(article) {
                normalized = String(normalized.dropFirst(article.count))
                break
            }
        }

        return normalized.trimmingCharacters(in: .whitespaces)
    }

    /// Save practice record to database
    private func savePracticeRecord() {
        guard let modelContext = modelContext else {
            print("⚠️ ModelContext not available, skipping practice record save")
            return
        }

        let accuracy = Double(wordsWon) / Double(max(1, wordsCompleted))
        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Hangman Game",
            wordsStudied: wordsCompleted,
            accuracy: accuracy,
            timeSpent: 0
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            print("✅ Hangman record saved: \(wordsWon)/\(wordsCompleted) won")

            // Award points
            PointsManager.shared.awardStars(points: totalPoints, modelContext: modelContext, reason: "Hangman game session")

            // Update WordProgress for all played words
            updateWordProgress(context: modelContext)

            // Track achievements
            trackAchievements(accuracy: accuracy, context: modelContext)

        } catch {
            print("❌ Failed to save Hangman record: \(error)")
        }
    }

    /// Update WordProgress for all words played in this game session
    private func updateWordProgress(context: ModelContext) {
        // Get or create UserProgress
        let userProgressDescriptor = FetchDescriptor<UserProgress>()
        let userProgress: UserProgress
        if let existing = try? context.fetch(userProgressDescriptor).first {
            userProgress = existing
        } else {
            userProgress = UserProgress()
            context.insert(userProgress)
        }

        // Update progress for all words played (0 to currentWordIndex)
        let playedWords = Array(words.prefix(currentWordIndex))

        for word in playedWords {
            // Try to find existing WordProgress - fetch all and filter in Swift
            let allProgressDescriptor = FetchDescriptor<WordProgress>()
            let allProgress = (try? context.fetch(allProgressDescriptor)) ?? []
            let existingProgress = allProgress.first { $0.word?.id == word.id }

            if let existingProgress = existingProgress {
                // Update existing progress
                existingProgress.lastReviewed = Date()
            } else {
                // Create new WordProgress
                let newProgress = WordProgress()
                newProgress.word = word
                newProgress.userProgress = userProgress
                newProgress.lastReviewed = Date()
                context.insert(newProgress)
            }
        }

        do {
            try context.save()
            print("✅ Updated WordProgress for \(playedWords.count) words")
        } catch {
            print("❌ Failed to update WordProgress: \(error)")
        }
    }

    /// Track achievements for this game session
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
                let isPerfect20 = wordsCompleted >= 20
                AchievementManager.shared.checkPerfectPractice(
                    perfectCount: perfectRecords.count,
                    isPerfect20: isPerfect20,
                    context: context
                )
            }
        }

        // Check for perfect Hangman game (no wrong guesses for at least one word)
        if hasPerfectWord {
            AchievementManager.shared.checkHangmanPerfect(context: context)
        }

        // Check special time-based achievements
        AchievementManager.shared.checkSpecialAchievements(context: context)

        // Check learning milestones
        let wordProgressDescriptor = FetchDescriptor<WordProgress>(
            predicate: #Predicate { $0.lastReviewed != nil }
        )
        if let wordProgresses = try? context.fetch(wordProgressDescriptor) {
            AchievementManager.shared.checkLearningMilestones(
                wordCount: wordProgresses.count,
                context: context
            )
        }
    }
}
