//
//  HangmanGameView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//

import SwiftUI
import SwiftData

struct HangmanGameView: View {
    let unite: Unite

    @Environment(\.modelContext) private var modelContext
    @State private var currentWord: Word?
    @State private var guessedLetters: Set<Character> = []
    @State private var wrongGuesses: Int = 0
    @State private var gameState: GameState = .playing
    @State private var score: Int = 0
    @State private var wordsPlayed: Int = 0

    private let maxWrongGuesses = 6
    private let alphabet = "abcdefghijklmnopqrstuvwxyz"

    enum GameState {
        case playing
        case won
        case lost
    }

    var body: some View {
        VStack(spacing: 20) {
            // 分数和进度
            HStack {
                Text("分数: \(score)")
                    .font(.headline)
                Spacer()
                Text("已玩: \(wordsPlayed)")
                    .font(.headline)
            }
            .padding(.horizontal)

            // Hangman绘图区域 - 固定宽度
            HangmanCanvas(wrongGuesses: wrongGuesses, maxGuesses: maxWrongGuesses)
                .frame(width: 280, height: 280)  // 固定尺寸，防止宽度变化
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding()

            // 单词显示区域
            if let word = currentWord {
                WordDisplay(word: word, guessedLetters: guessedLetters)
                    .padding()
            }

            // 游戏状态提示
            if gameState != .playing {
                GameResult(
                    gameState: gameState,
                    word: currentWord,
                    onNextWord: nextWord,
                    onRestart: restartGame
                )
            } else {
                // 字母键盘
                LetterKeyboard(
                    guessedLetters: guessedLetters,
                    onLetterTapped: handleLetterGuess
                )
                .padding()
            }
        }
        .navigationTitle("Hangman - \(unite.title)")
        .onAppear {
            loadNewWord()
        }
    }

    // MARK: - 游戏逻辑

    private func loadNewWord() {
        let allWords = getAllWords(from: unite)
        guard !allWords.isEmpty else { return }

        currentWord = allWords.randomElement()
        guessedLetters.removeAll()
        wrongGuesses = 0
        gameState = .playing
    }

    private func getAllWords(from unite: Unite) -> [Word] {
        var words: [Word] = []
        for section in unite.sections {
            for sectionWord in section.sectionWords {
                if let word = sectionWord.word {
                    words.append(word)
                }
            }
        }
        return words
    }

    private func handleLetterGuess(_ letter: Character) {
        guard gameState == .playing else { return }
        guard !guessedLetters.contains(letter) else { return }

        guessedLetters.insert(letter)

        guard let word = currentWord else { return }
        let normalizedCanonical = word.canonical.lowercased().folding(options: .diacriticInsensitive, locale: .current)

        if !normalizedCanonical.contains(letter) {
            wrongGuesses += 1

            if wrongGuesses >= maxWrongGuesses {
                gameState = .lost
            }
        } else {
            // 检查是否猜完了所有字母
            let allLetters = Set(normalizedCanonical.filter { $0.isLetter })
            if allLetters.isSubset(of: guessedLetters) {
                gameState = .won
                score += 10
            }
        }
    }

    private func nextWord() {
        wordsPlayed += 1
        loadNewWord()
    }

    private func restartGame() {
        score = 0
        wordsPlayed = 0
        loadNewWord()
    }
}

// MARK: - Hangman Canvas绘图
struct HangmanCanvas: View {
    let wrongGuesses: Int
    let maxGuesses: Int

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height

            // 绘制底座
            if wrongGuesses >= 0 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.1, y: height * 0.9))
                path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.9))
                context.stroke(path, with: .color(.black), lineWidth: 3)
            }

            // 绘制立柱
            if wrongGuesses >= 1 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.2, y: height * 0.9))
                path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.1))
                context.stroke(path, with: .color(.black), lineWidth: 3)
            }

            // 绘制横梁
            if wrongGuesses >= 2 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.2, y: height * 0.1))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.1))
                context.stroke(path, with: .color(.black), lineWidth: 3)
            }

            // 绘制绳子
            if wrongGuesses >= 3 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.6, y: height * 0.1))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.25))
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }

            // 绘制头部
            if wrongGuesses >= 4 {
                let center = CGPoint(x: width * 0.6, y: height * 0.32)
                let radius = height * 0.07
                context.stroke(Circle().path(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)), with: .color(.black), lineWidth: 2)
            }

            // 绘制身体
            if wrongGuesses >= 5 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.6, y: height * 0.39))
                path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.6))
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }

            // 绘制左手
            if wrongGuesses >= 6 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.6, y: height * 0.45))
                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.5))
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }

            // 绘制右手（如果有更多错误）
            if wrongGuesses >= 7 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.6, y: height * 0.45))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.5))
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }

            // 绘制左腿
            if wrongGuesses >= 8 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.6, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.75))
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }

            // 绘制右腿
            if wrongGuesses >= 9 {
                var path = Path()
                path.move(to: CGPoint(x: width * 0.6, y: height * 0.6))
                path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.75))
                context.stroke(path, with: .color(.black), lineWidth: 2)
            }
        }
    }
}

// MARK: - 单词显示组件
struct WordDisplay: View {
    let word: Word
    let guessedLetters: Set<Character>

    var body: some View {
        VStack(spacing: 10) {
            // 显示中文提示
            Text(word.chinese)
                .font(.title3)
                .foregroundColor(.secondary)

            // 显示单词（用下划线表示未猜出的字母）
            HStack(spacing: 8) {
                ForEach(Array(word.canonical.lowercased()), id: \.self) { char in
                    if char.isLetter {
                        let normalizedChar = String(char).folding(options: .diacriticInsensitive, locale: .current).first ?? char
                        if guessedLetters.contains(normalizedChar) {
                            Text(String(char).uppercased())
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(minWidth: 30)
                        } else {
                            Text("_")
                                .font(.title)
                                .frame(minWidth: 30)
                        }
                    } else {
                        Text(String(char))
                            .font(.title)
                            .frame(minWidth: 15)
                    }
                }
            }
        }
    }
}

// MARK: - 字母键盘
struct LetterKeyboard: View {
    let guessedLetters: Set<Character>
    let onLetterTapped: (Character) -> Void

    private let rows = [
        "abcdefghij",
        "klmnopqr",
        "stuvwxyz"
    ]

    var body: some View {
        VStack(spacing: 8) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 6) {
                    ForEach(Array(row), id: \.self) { letter in
                        Button(action: {
                            onLetterTapped(letter)
                        }) {
                            Text(String(letter).uppercased())
                                .font(.headline)
                                .frame(width: 28, height: 40)
                                .background(guessedLetters.contains(letter) ? Color.gray : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .disabled(guessedLetters.contains(letter))
                    }
                }
            }
        }
    }
}

// MARK: - 游戏结果显示
struct GameResult: View {
    let gameState: HangmanGameView.GameState
    let word: Word?
    let onNextWord: () -> Void
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            if gameState == .won {
                Text("🎉 恭喜，你赢了！")
                    .font(.title)
                    .foregroundColor(.green)
            } else {
                Text("😢 游戏结束")
                    .font(.title)
                    .foregroundColor(.red)

                if let word = word {
                    Text("正确答案: \(word.canonical)")
                        .font(.title2)
                }
            }

            HStack(spacing: 20) {
                Button("下一个单词") {
                    onNextWord()
                }
                .buttonStyle(.borderedProminent)

                Button("重新开始") {
                    onRestart()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

#Preview {
    NavigationView {
        HangmanGameView(unite: Unite(id: "test", number: 1, title: "Test Unite", isUnlocked: true, requiredStars: 0))
    }
    .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                          AudioFile.self, AudioSegment.self, UserProgress.self,
                          WordProgress.self, PracticeRecord.self, SectionWord.self], inMemory: true)
}
