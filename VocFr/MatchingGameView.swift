//
//  MatchingGameView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//

import SwiftUI
import SwiftData

struct MatchingGameView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unites: [Unite]

    @State private var matchingCards: [MatchingCard] = []
    @State private var selectedCards: [MatchingCard] = []
    @State private var matchedPairs: Set<UUID> = []
    @State private var score: Int = 0
    @State private var attempts: Int = 0
    @State private var isGameComplete: Bool = false

    private let pairsCount = 10

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 分数和进度
                HStack {
                    VStack(alignment: .leading) {
                        Text("分数: \(score)")
                            .font(.headline)
                        Text("尝试次数: \(attempts)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Text("已配对: \(matchedPairs.count / 2)/\(pairsCount)")
                        .font(.headline)
                }
                .padding(.horizontal)

                if isGameComplete {
                    // 游戏完成界面
                    VStack(spacing: 20) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.yellow)

                        Text("🎉 恭喜完成！")
                            .font(.title)
                            .fontWeight(.bold)

                        Text("最终分数: \(score)")
                            .font(.title2)

                        Text("总尝试次数: \(attempts)")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Button("重新开始") {
                            restartGame()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                } else {
                    // 配对卡片网格
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                            ForEach(matchingCards) { card in
                                MatchingCardView(
                                    card: card,
                                    isFlipped: selectedCards.contains(where: { $0.id == card.id }) || matchedPairs.contains(card.id),
                                    isMatched: matchedPairs.contains(card.id)
                                )
                                .onTapGesture {
                                    handleCardTap(card)
                                }
                            }
                        }
                        .padding()
                    }
                }

                Spacer()
            }
            .navigationTitle("配对游戏")
            .onAppear {
                if matchingCards.isEmpty {
                    startGame()
                }
            }
        }
    }

    // MARK: - 游戏逻辑

    private func startGame() {
        // 从所有已解锁单元中获取单词
        let allWords = getAllLearnedWords()
        guard allWords.count >= pairsCount else {
            print("单词数量不足，需要至少 \(pairsCount) 个单词")
            return
        }

        // 随机选择pairsCount个单词
        let selectedWords = Array(allWords.shuffled().prefix(pairsCount))

        // 创建配对卡片（法语和中文）
        var cards: [MatchingCard] = []
        for word in selectedWords {
            let pairId = UUID()
            // 法语卡片
            cards.append(MatchingCard(
                id: UUID(),
                pairId: pairId,
                displayText: word.canonical,
                word: word,
                isFrench: true
            ))
            // 中文卡片
            cards.append(MatchingCard(
                id: UUID(),
                pairId: pairId,
                displayText: word.chinese,
                word: word,
                isFrench: false
            ))
        }

        // 打乱卡片
        matchingCards = cards.shuffled()
        selectedCards.removeAll()
        matchedPairs.removeAll()
        score = 0
        attempts = 0
        isGameComplete = false
    }

    private func getAllLearnedWords() -> [Word] {
        var words: [Word] = []
        for unite in unites where unite.isUnlocked {
            for section in unite.sections {
                for sectionWord in section.sectionWords {
                    if let word = sectionWord.word {
                        words.append(word)
                    }
                }
            }
        }
        return words
    }

    private func handleCardTap(_ card: MatchingCard) {
        // 如果已经配对或已经选中，不处理
        guard !matchedPairs.contains(card.id) else { return }
        guard selectedCards.count < 2 else { return }
        guard !selectedCards.contains(where: { $0.id == card.id }) else { return }

        selectedCards.append(card)

        if selectedCards.count == 2 {
            attempts += 1
            checkForMatch()
        }
    }

    private func checkForMatch() {
        guard selectedCards.count == 2 else { return }

        let card1 = selectedCards[0]
        let card2 = selectedCards[1]

        // 检查是否配对成功（pairId相同且一个是法语一个是中文）
        if card1.pairId == card2.pairId && card1.isFrench != card2.isFrench {
            // 配对成功
            matchedPairs.insert(card1.id)
            matchedPairs.insert(card2.id)
            score += 10

            // 检查游戏是否完成
            if matchedPairs.count == matchingCards.count {
                isGameComplete = true
            }

            selectedCards.removeAll()
        } else {
            // 配对失败，延迟后翻回
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                selectedCards.removeAll()
            }
        }
    }

    private func restartGame() {
        matchingCards.removeAll()
        selectedCards.removeAll()
        matchedPairs.removeAll()
        score = 0
        attempts = 0
        isGameComplete = false
        startGame()
    }
}

// MARK: - 配对卡片数据模型
struct MatchingCard: Identifiable {
    let id: UUID
    let pairId: UUID
    let displayText: String
    let word: Word
    let isFrench: Bool
}

// MARK: - 配对卡片视图组件
struct MatchingCardView: View {
    let card: MatchingCard
    let isFlipped: Bool
    let isMatched: Bool

    var body: some View {
        ZStack {
            // 卡片背面
            RoundedRectangle(cornerRadius: 12)
                .fill(isMatched ? Color.green.opacity(0.3) : Color.blue.opacity(0.7))
                .overlay(
                    Image(systemName: "questionmark")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )
                .opacity(isFlipped ? 0 : 1)

            // 卡片正面
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .overlay(
                    VStack(spacing: 8) {
                        Text(card.displayText)
                            .font(card.isFrench ? .title3 : .title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)

                        Text(card.isFrench ? "FR" : "中文")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(card.isFrench ? Color.blue.opacity(0.2) : Color.orange.opacity(0.2))
                            .cornerRadius(4)
                    }
                    .padding()
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isMatched ? Color.green : Color.blue.opacity(0.3), lineWidth: 2)
                )
                .opacity(isFlipped ? 1 : 0)
        }
        .frame(height: 120)
        .rotation3DEffect(
            .degrees(isFlipped ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isFlipped)
    }
}

#Preview {
    MatchingGameView()
        .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                              AudioFile.self, AudioSegment.self, UserProgress.self,
                              WordProgress.self, PracticeRecord.self, SectionWord.self], inMemory: true)
}
