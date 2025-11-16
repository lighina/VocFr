//
//  GamesView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//

import SwiftUI
import SwiftData

struct GamesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unites: [Unite]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 游戏选择区
                Text("选择游戏")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                // 游戏卡片
                VStack(spacing: 15) {
                    // Hangman游戏
                    NavigationLink(destination: HangmanUniteSelectionView()) {
                        GameCard(
                            icon: "figure.stand",
                            title: "Hangman (吊人游戏)",
                            description: "猜单词拼写，挑战你的词汇量",
                            color: .blue
                        )
                    }

                    // 配对游戏
                    NavigationLink(destination: MatchingGameView()) {
                        GameCard(
                            icon: "rectangle.grid.2x2",
                            title: "配对游戏",
                            description: "匹配法语单词和中文意思",
                            color: .green
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("游戏")
        }
    }
}

// 游戏卡片组件
struct GameCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// Hangman单元选择视图
struct HangmanUniteSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var unites: [Unite]

    var body: some View {
        List {
            ForEach(unites.sorted(by: { $0.number < $1.number })) { unite in
                NavigationLink {
                    HangmanGameView(unite: unite)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unité \(unite.number): \(unite.title)")
                                .font(.headline)
                            Text("\(totalWordsCount(for: unite)) 个单词")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if unite.isUnlocked {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "lock")
                                .foregroundColor(.orange)
                        }
                    }
                }
                .disabled(!unite.isUnlocked)
                .opacity(unite.isUnlocked ? 1.0 : 0.6)
            }
        }
        .navigationTitle("选择单元")
    }

    private func totalWordsCount(for unite: Unite) -> Int {
        return unite.sections.reduce(0) { $0 + $1.sectionWords.count }
    }
}

#Preview {
    GamesView()
        .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                              AudioFile.self, AudioSegment.self, UserProgress.self,
                              WordProgress.self, PracticeRecord.self, SectionWord.self], inMemory: true)
}
