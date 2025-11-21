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

    let unite: Unite

    init(unite: Unite) {
        self.unite = unite
        let vm = HangmanViewModel(unite: unite, modelContext: nil)
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
        .navigationTitle("Hangman: Unité \(unite.number)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Unité \(unite.number)")
                    }
                }
            }
        }
        .onAppear {
            // Inject model context after view appears
            if !hasInitializedContext {
                viewModel = HangmanViewModel(unite: unite, modelContext: modelContext)
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
            .frame(width: 200, height: 200)  // 减小尺寸以适应窗口
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }


    // MARK: - Letter Grid

    private var letterGrid: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let columnsCount = isLandscape ? 10 : 7
            let spacing: CGFloat = 8
            
            // Calculate button size dynamically to fit screen width
            // Consider horizontal padding (32 total) from parent
            let availableWidth = geometry.size.width - 32
            let totalSpacing = CGFloat(columnsCount - 1) * spacing
            let calculatedButtonSize = (availableWidth - totalSpacing) / CGFloat(columnsCount)
            let buttonSize = max(calculatedButtonSize, 35) // Minimum 35pt for usability
            
            // Create fixed-width columns for consistent spacing
            let columns = Array(repeating: GridItem(.fixed(buttonSize), spacing: spacing), count: columnsCount)
            
            VStack(spacing: 12) {
                Text("hangman.tap.letter".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: columns, spacing: spacing) {
                    ForEach(viewModel.availableLetters, id: \.self) { letter in
                        letterButton(letter, size: buttonSize)
                    }
                }
            }
        }
        .frame(height: 200) // Fixed height for the letter grid area
    }
    
    private func letterButton(_ letter: Character, size: CGFloat) -> some View {
        let isGuessed = viewModel.guessedLetters.contains(letter)
        let isInWord = viewModel.wordToGuess.contains(letter)
    
        return Button(action: {
            viewModel.guessLetter(letter)
        }) {
            Text(String(letter).uppercased())
                .font(.system(size: 16, weight: .semibold))
                .frame(width: size, height: size)
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

            // Only show Retry button when won, not when lost
            if viewModel.gameState == .won {
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
            } else {
                // Lost state - only show Next button
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

    let unite = Unite(id: "u1", number: 1, title: "Sample Unite", isUnlocked: true, requiredStars: 0)
    let section = Section(id: "sample", name: "Sample", orderIndex: 0)
    section.unite = unite
    unite.sections.append(section)

    let word = Word(id: "w1", canonical: "bonjour", chinese: "你好", imageName: "", partOfSpeech: .noun, category: "greetings")
    let sectionWord = SectionWord(orderIndex: 0)
    sectionWord.section = section
    sectionWord.word = word
    section.sectionWords.append(sectionWord)
    word.sectionWords.append(sectionWord)

    context.insert(unite)
    context.insert(section)
    context.insert(word)
    context.insert(sectionWord)

    return NavigationStack {
        HangmanGameView(unite: unite)
            .modelContainer(container)
    }
}

// MARK: - Hangman Canvas

struct HangmanCanvas: View {
    let incorrectGuesses: Int

    var body: some View {
        Canvas { context, size in
            let lineWidth: CGFloat = 3
            let baseY = size.height * 0.9
            let poleX = size.width * 0.3
            let beamY = size.height * 0.15
            let ropeX = size.width * 0.7

            // Draw based on number of incorrect guesses
            if incorrectGuesses >= 1 {
                // Base
                var basePath = Path()
                basePath.move(to: CGPoint(x: poleX - 40, y: baseY))
                basePath.addLine(to: CGPoint(x: poleX + 40, y: baseY))
                context.stroke(basePath, with: .color(.primary), lineWidth: lineWidth)
            }

            if incorrectGuesses >= 2 {
                // Pole
                var polePath = Path()
                polePath.move(to: CGPoint(x: poleX, y: baseY))
                polePath.addLine(to: CGPoint(x: poleX, y: beamY))
                context.stroke(polePath, with: .color(.primary), lineWidth: lineWidth)
            }

            if incorrectGuesses >= 3 {
                // Top beam
                var beamPath = Path()
                beamPath.move(to: CGPoint(x: poleX, y: beamY))
                beamPath.addLine(to: CGPoint(x: ropeX, y: beamY))
                context.stroke(beamPath, with: .color(.primary), lineWidth: lineWidth)
            }

            if incorrectGuesses >= 4 {
                // Rope
                var ropePath = Path()
                ropePath.move(to: CGPoint(x: ropeX, y: beamY))
                ropePath.addLine(to: CGPoint(x: ropeX, y: beamY + 30))
                context.stroke(ropePath, with: .color(.primary), lineWidth: lineWidth)
            }

            let headY = beamY + 50
            let headRadius: CGFloat = 20

            if incorrectGuesses >= 5 {
                // Head
                let headRect = CGRect(
                    x: ropeX - headRadius,
                    y: headY - headRadius,
                    width: headRadius * 2,
                    height: headRadius * 2
                )
                context.stroke(
                    Circle().path(in: headRect),
                    with: .color(.primary),
                    lineWidth: lineWidth
                )
            }

            let bodyTop = headY + headRadius
            let bodyBottom = bodyTop + 50

            if incorrectGuesses >= 6 {
                // Body
                var bodyPath = Path()
                bodyPath.move(to: CGPoint(x: ropeX, y: bodyTop))
                bodyPath.addLine(to: CGPoint(x: ropeX, y: bodyBottom))
                context.stroke(bodyPath, with: .color(.primary), lineWidth: lineWidth)
            }

            let armY = bodyTop + 15

            if incorrectGuesses >= 7 {
                // Left arm
                var leftArmPath = Path()
                leftArmPath.move(to: CGPoint(x: ropeX, y: armY))
                leftArmPath.addLine(to: CGPoint(x: ropeX - 25, y: armY + 20))
                context.stroke(leftArmPath, with: .color(.primary), lineWidth: lineWidth)
            }

            if incorrectGuesses >= 8 {
                // Right arm
                var rightArmPath = Path()
                rightArmPath.move(to: CGPoint(x: ropeX, y: armY))
                rightArmPath.addLine(to: CGPoint(x: ropeX + 25, y: armY + 20))
                context.stroke(rightArmPath, with: .color(.primary), lineWidth: lineWidth)
            }

            if incorrectGuesses >= 9 {
                // Left leg
                var leftLegPath = Path()
                leftLegPath.move(to: CGPoint(x: ropeX, y: bodyBottom))
                leftLegPath.addLine(to: CGPoint(x: ropeX - 20, y: bodyBottom + 30))
                context.stroke(leftLegPath, with: .color(.primary), lineWidth: lineWidth)
            }

            if incorrectGuesses >= 10 {
                // Right leg
                var rightLegPath = Path()
                rightLegPath.move(to: CGPoint(x: ropeX, y: bodyBottom))
                rightLegPath.addLine(to: CGPoint(x: ropeX + 20, y: bodyBottom + 30))
                context.stroke(rightLegPath, with: .color(.primary), lineWidth: lineWidth)
            }
        }
    }
}
