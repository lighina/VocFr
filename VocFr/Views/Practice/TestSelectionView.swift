//
//  TestSelectionView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Test unit selection view
//

import SwiftUI
import SwiftData

struct TestSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var unites: [Unite]
    @Query private var testRecords: [TestRecord]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("test.select.unite".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)

                // Comprehensive Test
                NavigationLink(destination: TestSessionView(unite: nil, allWords: collectAllWords())) {
                    TestUnitCard(
                        title: "test.comprehensive".localized,
                        subtitle: "test.all.units".localized,
                        wordCount: collectAllWords().count,
                        bestScore: getBestScore(uniteId: nil),
                        color: .purple
                    )
                }
                .padding(.horizontal)

                // Unite Tests
                VStack(spacing: 12) {
                    ForEach(unites.sorted(by: { $0.number < $1.number })) { unite in
                        if unite.isUnlocked {
                            NavigationLink(destination: TestSessionView(unite: unite, allWords: [])) {
                                TestUnitCard(
                                    title: "Unité \(unite.number)",
                                    subtitle: unite.title,
                                    wordCount: countWords(in: unite),
                                    bestScore: getBestScore(uniteId: unite.id),
                                    color: .blue
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle("test.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("common.done".localized)
                    }
                }
            }
        }
    }

    private func collectAllWords() -> [Word] {
        var allWords: [Word] = []
        var seenIds = Set<String>()

        for unite in unites where unite.isUnlocked {
            for section in unite.sections {
                for sectionWord in section.sectionWords {
                    if let word = sectionWord.word,
                       !seenIds.contains(word.id),
                       word.partOfSpeech != .other {
                        allWords.append(word)
                        seenIds.insert(word.id)
                    }
                }
            }
        }

        return allWords
    }

    private func countWords(in unite: Unite) -> Int {
        var count = 0
        for section in unite.sections {
            count += section.sectionWords.filter { $0.word?.partOfSpeech != .other }.count
        }
        return count
    }

    private func getBestScore(uniteId: String?) -> Int? {
        let filtered: [TestRecord]
        if let uniteId = uniteId {
            filtered = testRecords.filter { $0.uniteId == uniteId }
        } else {
            filtered = testRecords.filter { $0.uniteId == nil }
        }

        return filtered.map { $0.score }.max()
    }
}

// MARK: - Test Unit Card

struct TestUnitCard: View {
    let title: String
    let subtitle: String
    let wordCount: Int
    let bestScore: Int?
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    Text(String(format: "game.mode.words.count".localized, wordCount))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let best = bestScore {
                        Text(String(format: "test.best.score".localized, best))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    NavigationStack {
        TestSelectionView()
            .modelContainer(for: [Unite.self, TestRecord.self], inMemory: true)
    }
}
