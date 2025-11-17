//
//  TestResultView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Test result view
//

import SwiftUI

struct TestResultView: View {
    let result: TestResult
    let unite: Unite?
    let onDismiss: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer()

                // Star Rating
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Image(systemName: index < result.starRating ? "star.fill" : "star")
                            .font(.system(size: 40))
                            .foregroundColor(.yellow)
                    }
                }

                // Score
                Text("\(result.score)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundColor(scoreColor)

                Text(result.ratingText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(scoreColor)

                // Statistics
                VStack(spacing: 16) {
                    // Overall Stats
                    VStack(spacing: 12) {
                        StatRow(
                            icon: "checkmark.circle.fill",
                            label: "test.result.correct".localized,
                            value: "\(result.correctAnswers)/\(result.totalQuestions)",
                            color: .green
                        )

                        StatRow(
                            icon: "clock.fill",
                            label: "test.result.time".localized,
                            value: formatTime(result.timeSpent),
                            color: .blue
                        )

                        // Earned Stars
                        StatRow(
                            icon: "star.fill",
                            label: "⭐ Earned Stars",
                            value: "+\(result.score)",
                            color: .yellow
                        )

                        // Earned Gems
                        HStack {
                            Text("💎")
                                .font(.title3)
                                .frame(width: 24)

                            Text("Earned Gems")
                                .foregroundColor(.secondary)

                            Spacer()

                            Text("+\(result.score / 10)")
                                .fontWeight(.semibold)
                                .foregroundColor(.cyan)
                        }
                    }

                    Divider()

                    // Question Type Breakdown
                    VStack(spacing: 12) {
                        QuestionTypeRow(
                            label: "test.result.imageToWord".localized,
                            correct: result.imageToWordCorrect,
                            total: result.imageToWordTotal
                        )

                        QuestionTypeRow(
                            label: "test.result.audioToWord".localized,
                            correct: result.audioToWordCorrect,
                            total: result.audioToWordTotal
                        )

                        QuestionTypeRow(
                            label: "test.result.spelling".localized,
                            correct: result.spellingCorrect,
                            total: result.spellingTotal
                        )

                        QuestionTypeRow(
                            label: "test.result.genderGuess".localized,
                            correct: result.genderGuessCorrect,
                            total: result.genderGuessTotal
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Buttons
                VStack(spacing: 12) {
                    if hasWrongAnswers {
                        NavigationLink(destination: WrongAnswerBookView()) {
                            HStack {
                                Image(systemName: "book.fill")
                                Text("test.button.viewWrong".localized)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }

                    Button(action: onDismiss) {
                        HStack {
                            Image(systemName: "arrow.left.circle.fill")
                            Text("test.button.back".localized)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Computed Properties

    private var scoreColor: Color {
        switch result.starRating {
        case 3: return .green
        case 2: return .blue
        case 1: return .orange
        default: return .red
        }
    }

    private var hasWrongAnswers: Bool {
        result.correctAnswers < result.totalQuestions
    }

    // MARK: - Helpers

    private func formatTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Stat Row

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)

            Text(label)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Question Type Row

struct QuestionTypeRow: View {
    let label: String
    let correct: Int
    let total: Int

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            HStack(spacing: 4) {
                Text("\(correct)/\(total)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                if correct == total {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
    }
}

#Preview {
    let sampleResult = TestResult(
        score: 85,
        totalQuestions: 20,
        correctAnswers: 17,
        timeSpent: 450,
        questionResults: []
    )

    return NavigationStack {
        TestResultView(result: sampleResult, unite: nil) {
            // Dismiss action
        }
    }
}
