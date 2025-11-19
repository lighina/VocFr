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
    @State private var refreshTrigger: UUID = UUID()
    @State private var selectedCards: [MatchingCard] = []
    @State private var attempts: Int = 0
    @State private var matchedPairs: Int = 0
    @State private var isCompleted: Bool = false
    @State private var startTime: Date = Date()
    @State private var completionTime: TimeInterval = 0

    private let totalPairs = 6

    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            let columns = isLandscape ? [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ] : [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            VStack(spacing: 16) {
                if isCompleted {
                    completedView
                } else {
                    gameView(columns: columns, geometry: geometry)
                }
            }
            .padding()
            .navigationTitle("matching.game.all.words.title".localized)
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
                setupGame()
            }
        }
    }

    // MARK: - Game View

    private func gameView(columns: [GridItem], geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            // Header
            gameHeader

            // Instructions
            if matchedPairs == 0 && attempts == 0 {
                Text("matching.game.instruction.all".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Cards grid - dynamic layout based on orientation
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(cards) { card in
                        MatchingCardView(card: card) {
                            selectCard(card)
                        }
                        .aspectRatio(1.0, contentMode: .fit)
                    }
                }
                .id(refreshTrigger)
            }

            Spacer()
        }
    }

    // MARK: - Header

    private var gameHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("matching.game.matched.pairs".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(matchedPairs) / \(totalPairs)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("matching.game.attempts.count".localized)
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

            Text("matching.game.excellent".localized)
                .font(.title)
                .fontWeight(.bold)

            VStack(spacing: 12) {
                HStack {
                    Text("matching.game.time".localized)
                    Spacer()
                    Text(formatTime(completionTime))
                        .fontWeight(.bold)
                }

                HStack {
                    Text("matching.game.attempts.count".localized)
                    Spacer()
                    Text("\(attempts)")
                        .fontWeight(.bold)
                }

                HStack {
                    Text("matching.game.accuracy.rate".localized)
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
                    Text("matching.game.play.again".localized)
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
        var seenWordIds = Set<String>()

        for unite in unites {
            for section in unite.sections {
                for sectionWord in section.sectionWords {
                    if let word = sectionWord.word {
                        // Filter: no duplicates and no 'other' partOfSpeech
                        if !seenWordIds.contains(word.id) && word.partOfSpeech != .other {
                            allWords.append(word)
                            seenWordIds.insert(word.id)
                        }
                    }
                }
            }
        }

        // Shuffle and take first 6 words
        let selectedWords = Array(allWords.shuffled().prefix(totalPairs))

        // Create cards (2 per word: image and French text)
        var newCards: [MatchingCard] = []
        for word in selectedWords {
            // Image card
            newCards.append(MatchingCard(word: word, type: .image))

            // French text card
            newCards.append(MatchingCard(word: word, type: .text))
        }

        // Shuffle cards
        cards = newCards.shuffled()
        refreshTrigger = UUID()
        startTime = Date()
    }

    private func selectCard(_ card: MatchingCard) {
        // Find card index
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        // Ignore if card is already face up or matched
        guard !cards[index].isFaceUp && !cards[index].isMatched else { return }

        // Ignore if already selected 2 cards
        guard selectedCards.count < 2 else { return }

        // Flip card face up
        var newCards = cards
        newCards[index].isFaceUp = true
        cards = newCards
        refreshTrigger = UUID()

        selectedCards.append(cards[index])

        // Check for match if 2 cards are selected
        if selectedCards.count == 2 {
            attempts += 1

            let first = selectedCards[0]
            let second = selectedCards[1]

            // Check if they match (different types, same word)
            if first.matches(second) {
                // Match!
                markCardsAsMatched(first, second)
                matchedPairs += 1
                selectedCards.removeAll()

                SoundEffectManager.shared.playCorrectSound()

                // Check if game completed
                if matchedPairs == totalPairs {
                    completeGame()
                }
            } else {
                // No match - flip cards back after delay
                SoundEffectManager.shared.playIncorrectSound()

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.flipCardsBack(first, second)
                    self.selectedCards.removeAll()
                }
            }
        }
    }

    private func markCardsAsMatched(_ card1: MatchingCard, _ card2: MatchingCard) {
        var newCards = cards
        if let index1 = newCards.firstIndex(where: { $0.id == card1.id }) {
            newCards[index1].isMatched = true
        }
        if let index2 = newCards.firstIndex(where: { $0.id == card2.id }) {
            newCards[index2].isMatched = true
        }
        cards = newCards
        refreshTrigger = UUID()
    }

    private func flipCardsBack(_ card1: MatchingCard, _ card2: MatchingCard) {
        var newCards = cards
        if let index1 = newCards.firstIndex(where: { $0.id == card1.id }) {
            newCards[index1].isFaceUp = false
        }
        if let index2 = newCards.firstIndex(where: { $0.id == card2.id }) {
            newCards[index2].isFaceUp = false
        }
        cards = newCards
        refreshTrigger = UUID()
    }

    private func completeGame() {
        completionTime = Date().timeIntervalSince(startTime)
        isCompleted = true
        savePracticeRecord()

        // Check for speed achievement (12 seconds or less)
        AchievementManager.shared.checkMatchingSpeed(timeSpent: completionTime, context: modelContext)
    }

    private func resetGame() {
        selectedCards.removeAll()
        attempts = 0
        matchedPairs = 0
        isCompleted = false
        completionTime = 0
        setupGame()
    }

    private func calculateAccuracy() -> Int {
        guard attempts > 0 else { return 100 }
        return Int(Double(totalPairs) / Double(attempts) * 100)
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func savePracticeRecord() {
        let timeSpent = Date().timeIntervalSince(startTime)
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
