//
//  AllWordsMatchingGameView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Matching game with all learned words (fixed 10 pairs)
//

import SwiftUI
import SwiftData

struct AllWordsMatchingGameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let unites: [Unite]

    @State private var cards: [MatchingCard] = []
    @State private var selectedCards: [MatchingCard] = []
    @State private var matchedPairIds: Set<String> = []
    @State private var attempts: Int = 0
    @State private var matchedPairs: Int = 0
    @State private var isCompleted: Bool = false
    @State private var startTime: Date = Date()

    private let totalPairs = 10
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 16) {
            if isCompleted {
                completedView
            } else {
                gameView
            }
        }
        .padding()
        .navigationTitle("配对游戏")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("游戏")
                    }
                }
            }
        }
        .onAppear {
            setupGame()
        }
    }

    // MARK: - Game View

    private var gameView: some View {
        VStack(spacing: 20) {
            // Header
            gameHeader

            // Instructions
            if matchedPairs == 0 && attempts == 0 {
                Text("找出10对法语单词与中文翻译的配对")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Cards grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(cards) { card in
                        CardView(
                            card: card,
                            isSelected: selectedCards.contains(where: { $0.id == card.id }),
                            isMatched: matchedPairIds.contains(card.pairId)
                        ) {
                            selectCard(card)
                        }
                        .aspectRatio(0.7, contentMode: .fit)
                    }
                }
            }

            Spacer()
        }
    }

    // MARK: - Header

    private var gameHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("已配对")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(matchedPairs) / \(totalPairs)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("尝试次数")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(attempts)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("太棒了！")
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                HStack {
                    Text("配对数")
                    Spacer()
                    Text("\(matchedPairs)")
                        .fontWeight(.bold)
                }

                HStack {
                    Text("尝试次数")
                    Spacer()
                    Text("\(attempts)")
                        .fontWeight(.bold)
                }

                HStack {
                    Text("准确率")
                    Spacer()
                    Text("\(calculateAccuracy())%")
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            Button(action: {
                resetGame()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("再玩一次")
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

    // MARK: - Game Logic

    private func setupGame() {
        // Collect all words from all unlocked unites
        var allWords: [Word] = []
        for unite in unites {
            for section in unite.sections {
                for sectionWord in section.sectionWords {
                    if let word = sectionWord.word {
                        allWords.append(word)
                    }
                }
            }
        }

        // Shuffle and take first 10 words
        let selectedWords = Array(allWords.shuffled().prefix(totalPairs))

        // Create cards (2 per word: French and Chinese)
        var newCards: [MatchingCard] = []
        for (index, word) in selectedWords.enumerated() {
            let pairId = "pair_\(index)"

            // French card
            newCards.append(MatchingCard(
                id: UUID().uuidString,
                pairId: pairId,
                text: word.canonical,
                isFrench: true
            ))

            // Chinese card
            newCards.append(MatchingCard(
                id: UUID().uuidString,
                pairId: pairId,
                text: word.chinese,
                isFrench: false
            ))
        }

        // Shuffle cards
        cards = newCards.shuffled()
        startTime = Date()
    }

    private func selectCard(_ card: MatchingCard) {
        // Ignore if card already matched
        guard !matchedPairIds.contains(card.pairId) else { return }

        // Ignore if already selected
        guard !selectedCards.contains(where: { $0.id == card.id }) else { return }

        // Add to selection
        selectedCards.append(card)

        // Check if we have 2 cards selected
        if selectedCards.count == 2 {
            attempts += 1

            let first = selectedCards[0]
            let second = selectedCards[1]

            // Check if they match
            if first.pairId == second.pairId {
                // Match!
                matchedPairIds.insert(first.pairId)
                matchedPairs += 1
                selectedCards.removeAll()

                SoundEffectManager.shared.playCorrectSound()

                // Check if game completed
                if matchedPairs == totalPairs {
                    completeGame()
                }
            } else {
                // No match - deselect after delay
                SoundEffectManager.shared.playIncorrectSound()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    selectedCards.removeAll()
                }
            }
        }
    }

    private func completeGame() {
        isCompleted = true
        savePracticeRecord()
    }

    private func resetGame() {
        selectedCards.removeAll()
        matchedPairIds.removeAll()
        attempts = 0
        matchedPairs = 0
        isCompleted = false
        setupGame()
    }

    private func calculateAccuracy() -> Int {
        guard attempts > 0 else { return 100 }
        return Int(Double(totalPairs) / Double(attempts) * 100)
    }

    private func savePracticeRecord() {
        let timeSpent = Int(Date().timeIntervalSince(startTime))
        let accuracy = Double(totalPairs) / Double(max(1, attempts))

        let record = PracticeRecord(
            sessionDate: Date(),
            sessionType: "Matching Game - All Words",
            wordsStudied: totalPairs,
            accuracy: accuracy,
            timeSpent: timeSpent
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            let points = totalPairs * 2
            PointsManager.shared.awardStars(points: points, modelContext: modelContext, reason: "Matching game completed")
        } catch {
            print("❌ Failed to save matching game record: \(error)")
        }
    }
}

// MARK: - Matching Card Model

struct MatchingCard: Identifiable {
    let id: String
    let pairId: String
    let text: String
    let isFrench: Bool
}

// MARK: - Card View

struct CardView: View {
    let card: MatchingCard
    let isSelected: Bool
    let isMatched: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack {
                Text(card.text)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(cardTextColor)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(8)
            .background(cardBackground)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
            )
            .opacity(isMatched ? 0.3 : 1.0)
        }
        .disabled(isMatched)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.2), value: isMatched)
    }

    private var cardBackground: Color {
        if isMatched {
            return .green.opacity(0.2)
        } else if isSelected {
            return .blue.opacity(0.3)
        } else if card.isFrench {
            return Color(.systemGray6)
        } else {
            return .blue.opacity(0.1)
        }
    }

    private var cardTextColor: Color {
        if isMatched {
            return .green
        } else if isSelected {
            return .blue
        } else {
            return .primary
        }
    }

    private var borderColor: Color {
        if isMatched {
            return .green
        } else if isSelected {
            return .blue
        } else {
            return Color(.systemGray4)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Unite.self, Section.self, Word.self, configurations: config)
    let context = container.mainContext

    let unite = Unite(id: "u1", number: 1, title: "Test", isUnlocked: true, requiredStars: 0)
    context.insert(unite)

    return NavigationStack {
        AllWordsMatchingGameView(unites: [unite])
            .modelContainer(container)
    }
}
