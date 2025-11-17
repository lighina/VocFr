//
//  HangmanAllWordsView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Hangman game with all learned words
//

import SwiftUI
import SwiftData

struct HangmanAllWordsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HangmanAllWordsViewModel
    @State private var wordGuess: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var hasInitializedContext = false

    let unites: [Unite]

    init(unites: [Unite]) {
        self.unites = unites
        let vm = HangmanAllWordsViewModel(unites: unites, modelContext: nil)
        self._viewModel = State(initialValue: vm)
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.gameState == .sessionCompleted {
                completedView
            } else {
                gameView
            }
        }
        .navigationTitle("game.mode.hangman.all.words".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("game.mode.back.to.games".localized)
                    }
                }
            }
        }
        .onAppear {
            if !hasInitializedContext {
                viewModel = HangmanAllWordsViewModel(unites: unites, modelContext: modelContext)
                hasInitializedContext = true
            }
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: 0) {
            // Progress header
            HStack {
                Text(viewModel.progressText)
                    .font(.headline)
                Spacer()
                Text("🎯 \(viewModel.totalPoints) pts")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))

            ScrollView {
                VStack(spacing: 20) {
                    // Hangman figure
                    hangmanFigure
                        .padding(.top)

                    // Remaining guesses
                    Text("❤️ \(viewModel.remainingGuesses) / \(viewModel.maxIncorrectGuesses)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.remainingGuesses <= 3 ? .red : .primary)

                    // Display word with blanks
                    Text(viewModel.displayString)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    if viewModel.gameState == .playing {
                        // Letter grid
                        letterGrid
                            .padding(.horizontal)

                        // Word guess input
                        wordGuessSection
                            .padding(.horizontal)
                    } else {
                        // Game over section
                        gameOverSection
                    }

                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Hangman Figure

    private var hangmanFigure: some View {
        HangmanCanvas(incorrectGuesses: viewModel.incorrectGuesses)
            .frame(width: 200, height: 200)
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }

    // MARK: - Letter Grid

    private var letterGrid: some View {
        VStack(spacing: 12) {
            Text("hangman.tap.letter".localized)
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(viewModel.availableLetters, id: \.self) { letter in
                    letterButton(letter)
                }
            }
        }
    }

    private func letterButton(_ letter: Character) -> some View {
        let isGuessed = viewModel.guessedLetters.contains(letter)
        let isInWord = viewModel.wordToGuess.contains(letter)

        return Button(action: {
            viewModel.guessLetter(letter)
        }) {
            Text(String(letter).uppercased())
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 40, height: 40)
                .background(buttonColor(isGuessed: isGuessed, isInWord: isInWord))
                .foregroundColor(isGuessed ? .white : .primary)
                .cornerRadius(8)
        }
        .disabled(isGuessed || viewModel.isGameOver)
    }

    private func buttonColor(isGuessed: Bool, isInWord: Bool) -> Color {
        if !isGuessed {
            return Color(.systemGray5)
        } else if isInWord {
            return .green
        } else {
            return .red
        }
    }

    // MARK: - Word Guess Section

    private var wordGuessSection: some View {
        VStack(spacing: 12) {
            Divider()

            Text("hangman.guess.whole.word".localized)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                TextField("hangman.type.word".localized, text: $wordGuess)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isInputFocused)
                    .onSubmit {
                        submitWordGuess()
                    }

                Button(action: submitWordGuess) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(wordGuess.isEmpty)
            }
        }
    }

    private func submitWordGuess() {
        guard !wordGuess.isEmpty else { return }
        viewModel.guessWord(wordGuess)
        wordGuess = ""
        isInputFocused = false
    }

    // MARK: - Game Over Section

    private var gameOverSection: some View {
        VStack(spacing: 16) {
            if viewModel.gameState == .won {
                HStack(spacing: 8) {
                    Text("🎉")
                        .font(.system(size: 40))

                    Text("hangman.won.title".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }

                if let word = viewModel.currentWord {
                    Text(word.canonical)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.gameState == .lost {
                HStack(spacing: 8) {
                    Text("😢")
                        .font(.system(size: 40))

                    Text("hangman.lost.title".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }

                if let word = viewModel.currentWord {
                    VStack(spacing: 4) {
                        Text("hangman.correct.answer".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(word.canonical)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }

            HStack(spacing: 16) {
                Button(action: {
                    viewModel.restartWord()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("hangman.retry".localized)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
                }

                Button(action: {
                    viewModel.nextWord()
                }) {
                    HStack {
                        Text("hangman.next".localized)
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)

            Text("hangman.session.complete".localized)
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                HStack {
                    Text("hangman.words.completed".localized)
                    Spacer()
                    Text("\(viewModel.wordsCompleted)")
                        .fontWeight(.bold)
                }

                HStack {
                    Text("hangman.words.won".localized)
                    Spacer()
                    Text("\(viewModel.wordsWon)")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }

                HStack {
                    Text("hangman.win.rate".localized)
                    Spacer()
                    Text("\(viewModel.winRate)%")
                        .fontWeight(.bold)
                }

                Divider()

                HStack {
                    Text("hangman.total.points".localized)
                    Spacer()
                    Text("\(viewModel.totalPoints) pts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Button(action: {
                viewModel.restartSession()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("hangman.play.again".localized)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - ViewModel for All Words Hangman

@Observable
class HangmanAllWordsViewModel {
    // Copy of HangmanViewModel logic but for multiple unites
    let unites: [Unite]
    private let modelContext: ModelContext?

    // Game state
    var gameState: HangmanGameState = .playing
    var currentWord: Word?
    var wordToGuess: String = ""
    var displayString: String = ""
    var guessedLetters: Set<Character> = []
    var incorrectGuesses: Int = 0
    var remainingGuesses: Int = 10
    let maxIncorrectGuesses: Int = 10
    var totalPoints: Int = 0
    var wordsCompleted: Int = 0
    var wordsWon: Int = 0

    var availableLetters: [Character] = Array("abcdefghijklmnopqrstuvwxyzàâäéèêëïîôùûüÿçœæ")

    private var allWords: [Word] = []
    private var remainingWords: [Word] = []

    var isGameOver: Bool {
        gameState == .won || gameState == .lost
    }

    var progressText: String {
        "Word \(wordsCompleted + 1)"
    }

    var winRate: Int {
        guard wordsCompleted > 0 else { return 0 }
        return Int(Double(wordsWon) / Double(wordsCompleted) * 100)
    }

    init(unites: [Unite], modelContext: ModelContext?) {
        self.unites = unites
        self.modelContext = modelContext

        // Collect all words from all unites
        for unite in unites {
            for section in unite.sections {
                for sectionWord in section.sectionWords {
                    if let word = sectionWord.word {
                        allWords.append(word)
                    }
                }
            }
        }

        remainingWords = allWords.shuffled()
        loadNextWord()
    }

    func guessLetter(_ letter: Character) {
        guard !isGameOver else { return }

        let lowerLetter = Character(letter.lowercased())
        guard !guessedLetters.contains(lowerLetter) else { return }

        guessedLetters.insert(lowerLetter)

        if !wordToGuess.lowercased().contains(lowerLetter) {
            incorrectGuesses += 1
            remainingGuesses -= 1

            if remainingGuesses <= 0 {
                gameState = .lost
            }
        } else {
            updateDisplayString()

            if !displayString.contains("_") {
                gameState = .won
                let points = calculatePoints()
                totalPoints += points
                wordsWon += 1
            }
        }
    }

    func guessWord(_ word: String) {
        guard !isGameOver else { return }

        if word.lowercased() == wordToGuess.lowercased() {
            displayString = wordToGuess
            gameState = .won
            let points = calculatePoints()
            totalPoints += points
            wordsWon += 1
        } else {
            incorrectGuesses += 1
            remainingGuesses -= 1

            if remainingGuesses <= 0 {
                gameState = .lost
            }
        }
    }

    func nextWord() {
        wordsCompleted += 1

        if remainingWords.isEmpty {
            gameState = .sessionCompleted
            saveFinalRecord()
        } else {
            loadNextWord()
        }
    }

    func restartWord() {
        resetCurrentWord()
    }

    func restartSession() {
        totalPoints = 0
        wordsCompleted = 0
        wordsWon = 0
        remainingWords = allWords.shuffled()
        loadNextWord()
    }

    private func loadNextWord() {
        guard !remainingWords.isEmpty else {
            gameState = .sessionCompleted
            return
        }

        currentWord = remainingWords.removeFirst()
        resetCurrentWord()
    }

    private func resetCurrentWord() {
        guard let word = currentWord else { return }

        wordToGuess = word.canonical
        gameState = .playing
        guessedLetters.removeAll()
        incorrectGuesses = 0
        remainingGuesses = maxIncorrectGuesses
        updateDisplayString()
    }

    private func updateDisplayString() {
        displayString = wordToGuess.map { char in
            if char.isWhitespace {
                return " "
            } else if guessedLetters.contains(Character(char.lowercased())) {
                return String(char)
            } else {
                return "_"
            }
        }.joined(separator: " ")
    }

    private func calculatePoints() -> Int {
        let basePoints = 10
        let guessBonus = max(0, 10 - incorrectGuesses)
        return basePoints + guessBonus
    }

    private func saveFinalRecord() {
        guard let modelContext = modelContext else { return }

        let accuracy = Double(wordsWon) / Double(max(1, wordsCompleted))
        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Hangman - All Words",
            wordsStudied: wordsCompleted,
            accuracy: accuracy,
            timeSpent: 0
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            if totalPoints > 0 {
                PointsManager.shared.awardStars(points: totalPoints, modelContext: modelContext, reason: "Hangman game completed")
            }
        } catch {
            print("❌ Failed to save hangman record: \(error)")
        }
    }
}

enum HangmanGameState {
    case playing
    case won
    case lost
    case sessionCompleted
}
