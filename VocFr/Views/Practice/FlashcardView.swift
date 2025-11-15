//
//  FlashcardView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.2: Flashcard Mode - Main Interface
//

import SwiftUI
import SwiftData

struct FlashcardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: FlashcardViewModel

    init(section: Section) {
        self._viewModel = State(initialValue: FlashcardViewModel(section: section, modelContext: nil))
    }

    var body: some View {
        let title = String(format: "flashcard.title".localized, viewModel.sectionName)

        VStack(spacing: 20) {
            if viewModel.isCompleted {
                completedView
            } else if viewModel.currentWord != nil {
                reviewView
            } else {
                emptyView
            }
        }
        .padding()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text(viewModel.sectionName.capitalized)
                            .font(.system(size: 16))
                    }
                }
            }
        }
        .onAppear {
            // Set modelContext after view appears
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Review View

    private var reviewView: some View {
        VStack(spacing: 20) {
            // Progress header
            progressHeader

            // Statistics
            if let stats = viewModel.statistics {
                statisticsView(for: stats)
            }

            // Flashcard
            if let word = viewModel.currentWord {
                FlashcardCard(word: word, section: viewModel.section, isFaceUp: $viewModel.isFaceUp)
                    .padding(.horizontal)
            }

            Spacer()

            // Action buttons (only show when card is flipped)
            if viewModel.isFaceUp {
                actionButtons
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 8) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)

                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * viewModel.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)

            // Progress text
            HStack {
                Text("flashcard.progress".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text(viewModel.progressText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
        }
    }

    // MARK: - Statistics View

    private func statisticsView(for stats: FlashcardStatistics) -> some View {
        HStack(spacing: 16) {
            // Due cards
            statItem(
                icon: "clock",
                value: "\(stats.dueCards)",
                label: "flashcard.due".localized,
                color: .orange
            )

            Divider()
                .frame(height: 40)

            // New cards
            statItem(
                icon: "star.circle",
                value: "\(stats.newCards)",
                label: "flashcard.new".localized,
                color: .blue
            )

            Divider()
                .frame(height: 40)

            // Mastered
            statItem(
                icon: "checkmark.circle.fill",
                value: "\(stats.masteredCards)",
                label: "flashcard.mastered".localized,
                color: .green
            )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func statItem(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.headline)
                .fontWeight(.bold)

            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 16) {
            // Don't Know button
            Button(action: {
                withAnimation {
                    viewModel.markAsUnknown()
                }
            }) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                    Text("flashcard.dont.know".localized)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
            }

            // Know button
            Button(action: {
                withAnimation {
                    viewModel.markAsKnown()
                }
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("flashcard.know".localized)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
        }
        .padding(.bottom)
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("flashcard.completed.title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)

            // Session stats
            VStack(spacing: 16) {
                // Cards reviewed
                HStack {
                    Image(systemName: "square.stack.3d.up")
                        .foregroundColor(.blue)
                    Text("flashcard.cards.reviewed".localized)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.reviewedCount)")
                        .fontWeight(.semibold)
                }

                Divider()

                // Success rate
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.green)
                    Text("flashcard.success.rate".localized)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(viewModel.sessionSuccessRate * 100))%")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )

            // Restart button
            Button(action: {
                withAnimation {
                    viewModel.restartReview()
                }
            }) {
                Text("flashcard.restart".localized)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("flashcard.all.done".localized)
                .font(.title2)
                .fontWeight(.semibold)

            Text("flashcard.all.done.message".localized)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    let schema = Schema([Section.self, Word.self, FlashcardProgress.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    return NavigationView {
        FlashcardView(section: Section(id: "test", name: "Test Section", orderIndex: 1))
    }
    .modelContainer(container)
}
