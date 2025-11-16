//
//  HangmanGameView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Hangman word guessing game UI
//

import SwiftUI
import SwiftData

struct HangmanGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: HangmanViewModel
    @State private var wordGuess: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var hasInitializedContext = false

    let section: Section

    init(section: Section) {
        self.section = section
        let vm = HangmanViewModel(section: section, modelContext: nil)
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
        .navigationTitle("Hangman: \(viewModel.section.name.capitalized)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(viewModel.section.name.capitalized)
                    }
                }
            }
        }
        .onAppear {
            // Inject model context after view appears
            if !hasInitializedContext {
                viewModel = HangmanViewModel(section: section, modelContext: modelContext)
                hasInitializedContext = true
            }
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: 20) {
            // Progress
            HStack {
                Text(viewModel.progressText)
                    .font(.headline)
                Spacer()
                Text("🎯 \(viewModel.totalPoints) pts")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top)

            ScrollView {
                VStack(spacing: 24) {
                    // Hangman figure
                    hangmanFigure
                        .padding()

                    // Remaining guesses
                    Text("❤️ \(viewModel.remainingGuesses) / \(viewModel.maxIncorrectGuesses)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(viewModel.remainingGuesses <= 3 ? .red : .primary)

                    if let word = viewModel.currentWord {
                        // Word image
                        if let image = UIImage(named: word.imageName) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                                .cornerRadius(12)
                        }
                    }

                    // Display word with blanks
                    Text(viewModel.displayString)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.primary)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    if viewModel.gameState == .playing {
                        // Letter grid
                        letterGrid

                        // Word guess input
                        wordGuessSection
                    } else {
                        // Game over section
                        gameOverSection
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }
        }
    }

    // MARK: - Hangman Figure

    private var hangmanFigure: some View {
        Text(getHangmanAscii())
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .foregroundColor(.primary)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }

    private func getHangmanAscii() -> String {
        let stages = [
            // 0 incorrect
            """
              ┌─┐
              │
              │
              │
            ─────
            """,
            // 1 incorrect
            """
              ┌─┐
              │ O
              │
              │
            ─────
            """,
            // 2 incorrect
            """
              ┌─┐
              │ O
              │ |
              │
            ─────
            """,
            // 3 incorrect
            """
              ┌─┐
              │ O
              │ |\\
              │
            ─────
            """,
            // 4 incorrect
            """
              ┌─┐
              │ O
              │/|\\
              │
            ─────
            """,
            // 5 incorrect
            """
              ┌─┐
              │ O
              │/|\\
              │ |
            ─────
            """,
            // 6 incorrect
            """
              ┌─┐
              │ O
              │/|\\
              │ |
            ───|─
            """,
            // 7 incorrect
            """
              ┌─┐
              │ O
              │/|\\
              │ |
            ───|───
            """,
            // 8 incorrect
            """
              ┌─┐
              │ O
              │/|\\
              │/
            ───|───
            """,
            // 9 incorrect (game over)
            """
              ┌─┐
              │ O
              │/|\\
              │/ \\
            ───────
            """
        ]

        let index = min(viewModel.incorrectGuesses, stages.count - 1)
        return stages[index]
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
                Text("🎉")
                    .font(.system(size: 60))

                Text("hangman.won.title".localized)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.green)

                if let word = viewModel.currentWord {
                    Text(word.canonical)
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.gameState == .lost {
                Text("😢")
                    .font(.system(size: 60))

                Text("hangman.lost.title".localized)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.red)

                if let word = viewModel.currentWord {
                    VStack(spacing: 4) {
                        Text("hangman.correct.answer".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(word.canonical)
                            .font(.title2)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, configurations: config)
    let context = container.mainContext

    let section = Section(id: "sample", name: "Sample", orderIndex: 0)
    let word = Word(id: "w1", canonical: "bonjour", chinese: "你好", imageName: "", partOfSpeech: .noun, category: "greetings")
    let sectionWord = SectionWord(orderIndex: 0)
    sectionWord.section = section
    sectionWord.word = word
    section.sectionWords.append(sectionWord)
    word.sectionWords.append(sectionWord)

    context.insert(section)
    context.insert(word)
    context.insert(sectionWord)

    return NavigationStack {
        HangmanGameView(section: section)
            .modelContainer(container)
    }
}
