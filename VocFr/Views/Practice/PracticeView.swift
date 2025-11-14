import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PracticeViewModel

    init(section: Section) {
        // Initialize viewModel with section
        // modelContext will be set in onAppear
        self._viewModel = State(initialValue: PracticeViewModel(section: section, modelContext: nil))
    }

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.isCompleted {
                completedView
            } else if let word = viewModel.currentWord {
                practiceCard(for: word)
            } else {
                Text("practice.no.words".localized)
            }
        }
        .padding()
        .navigationTitle("practice.title".localized(viewModel.sectionName))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            // Set modelContext after view appears
            viewModel = PracticeViewModel(section: viewModel.section, modelContext: modelContext)
        }
    }

    private func practiceCard(for word: Word) -> some View {
        VStack(spacing: 30) {
            // Progress indicator
            HStack {
                Text(viewModel.progressText)
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text(viewModel.correctCountText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)

            // Question prompt
            Text("practice.question".localized)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            // Word image
            if !word.imageName.isEmpty && imageExists(named: word.imageName) {
                Image(word.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 250, maxHeight: 250)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            } else {
                // Placeholder
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 250, height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.6))
                    )
            }

            // Answer options (4 buttons)
            VStack(spacing: 12) {
                ForEach(Array(viewModel.currentOptions.enumerated()), id: \.element.id) { index, option in
                    answerButton(
                        text: option.canonical,
                        index: index,
                        isCorrect: option.id == word.id
                    )
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    /// Answer button with feedback
    private func answerButton(text: String, index: Int, isCorrect: Bool) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectAnswer(at: index)
            }
        }) {
            HStack {
                Text(text)
                    .font(.headline)
                    .foregroundColor(buttonForegroundColor(index: index, isCorrect: isCorrect))

                Spacer()

                // Show checkmark or X after selection
                if viewModel.selectedAnswerIndex == index {
                    Image(systemName: viewModel.isAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(viewModel.isAnswerCorrect ? .green : .red)
                        .font(.title3)
                } else if viewModel.selectedAnswerIndex != nil && isCorrect {
                    // Show correct answer if user selected wrong
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(buttonBackgroundColor(index: index, isCorrect: isCorrect))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(buttonBorderColor(index: index, isCorrect: isCorrect), lineWidth: 2)
            )
        }
        .disabled(viewModel.selectedAnswerIndex != nil)
    }

    /// Button foreground color based on state
    private func buttonForegroundColor(index: Int, isCorrect: Bool) -> Color {
        if viewModel.selectedAnswerIndex == index {
            return viewModel.isAnswerCorrect ? .white : .white
        } else if viewModel.selectedAnswerIndex != nil && isCorrect {
            return .white
        }
        return .primary
    }

    /// Button background color based on state
    private func buttonBackgroundColor(index: Int, isCorrect: Bool) -> Color {
        if viewModel.selectedAnswerIndex == index {
            return viewModel.isAnswerCorrect ? .green : .red
        } else if viewModel.selectedAnswerIndex != nil && isCorrect {
            return .green.opacity(0.8)
        }
        return Color(.systemGray6)
    }

    /// Button border color based on state
    private func buttonBorderColor(index: Int, isCorrect: Bool) -> Color {
        if viewModel.selectedAnswerIndex == index {
            return viewModel.isAnswerCorrect ? .green : .red
        } else if viewModel.selectedAnswerIndex != nil && isCorrect {
            return .green
        }
        return .clear
    }

    /// Check if an image exists in the asset catalog
    private func imageExists(named: String) -> Bool {
        #if os(iOS)
        return UIImage(named: named) != nil
        #elseif os(macOS)
        return NSImage(named: named) != nil
        #else
        return false
        #endif
    }

    private var completedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("practice.completed.title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("practice.accuracy".localized(viewModel.accuracyPercentage))
                .font(.title2)
                .foregroundColor(.secondary)

            Text("practice.results".localized(viewModel.correctCount, viewModel.totalWords))
                .font(.body)
                .foregroundColor(.secondary)

            // Points earned (Part B.1)
            if viewModel.pointsEarned > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)

                    Text("practice.points.earned".localized(viewModel.pointsEarned))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.yellow.opacity(0.2))
                )
            }

            Button("practice.button.retry".localized) {
                viewModel.restartPractice()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
    }
}

#Preview {
    NavigationView {
        PracticeView(section: Section(id: "test", name: "Test Section", orderIndex: 1))
    }
    .modelContainer(for: [Section.self, Word.self], inMemory: true)
}
