//
//  WrongAnswerBookView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Wrong answer book view - 错题本
//

import SwiftUI
import SwiftData

struct WrongAnswerBookView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<WrongAnswerRecord> { !$0.isMastered },
        sort: \WrongAnswerRecord.lastWrongDate,
        order: .reverse
    ) private var wrongAnswers: [WrongAnswerRecord]

    @Query private var allWords: [Word]

    var body: some View {
        Group {
            if wrongAnswers.isEmpty {
                emptyView
            } else {
                listView
            }
        }
        .navigationTitle("wrong.answer.book.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("wrong.answer.empty.title".localized)
                .font(.title)
                .fontWeight(.bold)

            Text("wrong.answer.empty.subtitle".localized)
                .foregroundColor(.secondary)
        }
    }

    // MARK: - List View

    private var listView: some View {
        List {
            SwiftUI.Section {
                Text(String(format: "wrong.answer.count".localized, wrongAnswers.count))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            ForEach(wrongAnswers) { record in
                if let word = findWord(id: record.wordId) {
                    WrongAnswerRow(record: record, word: word) {
                        markAsMastered(record)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func findWord(id: String) -> Word? {
        allWords.first { $0.id == id }
    }

    private func markAsMastered(_ record: WrongAnswerRecord) {
        record.isMastered = true
        record.isRetried = true
        try? modelContext.save()
    }
}

// MARK: - Wrong Answer Row

struct WrongAnswerRow: View {
    let record: WrongAnswerRecord
    let word: Word
    let onMastered: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(word.canonical)
                    .font(.headline)

                Spacer()

                Text(questionTypeLabel)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "wrong.answer.your.answer".localized, record.userAnswer))
                        .font(.subheadline)
                        .foregroundColor(.red)

                    Text(String(format: "wrong.answer.correct.answer".localized, record.correctAnswer))
                        .font(.subheadline)
                        .foregroundColor(.green)

                    Text(String(format: "wrong.answer.wrong.count".localized, record.wrongCount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onMastered) {
                    Image(systemName: "checkmark.circle")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var questionTypeLabel: String {
        guard let type = TestQuestionType(rawValue: record.questionType) else {
            return ""
        }

        switch type {
        case .imageToWord:
            return "wrong.answer.type.imageToWord".localized
        case .audioToWord:
            return "wrong.answer.type.audioToWord".localized
        case .spelling:
            return "wrong.answer.type.spelling".localized
        case .genderGuess:
            return "wrong.answer.type.genderGuess".localized
        }
    }
}

#Preview {
    NavigationStack {
        WrongAnswerBookView()
            .modelContainer(for: [WrongAnswerRecord.self, Word.self], inMemory: true)
    }
}
