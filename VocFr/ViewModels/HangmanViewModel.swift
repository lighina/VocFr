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

    enum GameState {
        case playing
        case won
        case lost
        case sessionCompleted
    }

    // MARK: - Computed Properties

    /// All words in the unite (from all sections)
    var words: [Word] {
        var allWords: [Word] = []
        for section in unite.sections.sorted(by: { $0.orderIndex < $1.orderIndex }) {
            let sectionWords = section.sectionWords
                .sorted(by: { $0.orderIndex < $1.orderIndex })
                .compactMap { $0.word }
            allWords.append(contentsOf: sectionWords)
        }
        return allWords
    }

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
        } catch {
            print("❌ Failed to save Hangman record: \(error)")
        }
    }
}
