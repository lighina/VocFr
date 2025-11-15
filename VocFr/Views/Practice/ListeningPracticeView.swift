//
//  ListeningPracticeView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.1.1: Listening Mode
//

import SwiftUI
import SwiftData

struct ListeningPracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ListeningPracticeViewModel
    @ObservedObject private var audioManager = AudioPlayerManager.shared

    init(section: Section) {
        // Initialize viewModel with section
        // modelContext will be set in onAppear
        self._viewModel = State(initialValue: ListeningPracticeViewModel(section: section, modelContext: nil))
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
        .navigationTitle("listening.practice.title".localized(viewModel.sectionName))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Set modelContext after view appears
            viewModel = ListeningPracticeViewModel(section: viewModel.section, modelContext: modelContext)
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
            Text("listening.practice.question".localized)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // Audio player button (replacing image)
            VStack(spacing: 16) {
                // Large play button
                Button(action: {
                    playAudio(for: word)
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)

                        Image(systemName: audioManager.isPlaying ? "stop.fill" : "speaker.wave.3.fill")
                            .font(.system(size: 50, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .disabled(!viewModel.canPlay || audioManager.isPlaying)
                .opacity((viewModel.canPlay && !audioManager.isPlaying) ? 1.0 : 0.5)

                // Play count indicator
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("listening.practice.play.count".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.playCountText)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.canPlay ? .blue : .red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)

                // Instruction text
                if viewModel.selectedAnswerIndex == nil {
                    Text("listening.practice.instruction".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.vertical, 20)

            // Answer options (4 buttons in 2×2 grid)
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(Array(viewModel.currentOptions.enumerated()), id: \.element.id) { index, option in
                    answerButton(
                        text: option.canonical,
                        index: index,
                        isCorrect: option.id == word.id
                    )
                    .aspectRatio(0.85, contentMode: .fit)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .onAppear {
            // Auto-play audio on first appearance
            if viewModel.shouldAutoPlay() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playAudio(for: word)
                    viewModel.markAutoPlayed()
                }
            }
        }
        .onChange(of: viewModel.currentWordIndex) { _, _ in
            // Auto-play audio when word changes
            if viewModel.shouldAutoPlay() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playAudio(for: word)
                    viewModel.markAutoPlayed()
                }
            }
        }
    }

    /// Answer button with image feedback
    private func answerButton(text: String, index: Int, isCorrect: Bool) -> some View {
        let word = viewModel.currentOptions[index]

        return Button(action: {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectAnswer(at: index)
            }
        }) {
            VStack(spacing: 8) {
                // Word image
                if let image = UIImage(named: word.imageName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .cornerRadius(8)
                } else {
                    // Fallback if image not found
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 80)
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
                }

                // Word text (smaller, below image)
                Text(text)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(buttonForegroundColor(index: index, isCorrect: isCorrect))

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

    /// Play audio for word
    private func playAudio(for word: Word) {
        guard viewModel.canPlay else { return }

        // Increment play count
        viewModel.incrementPlayCount()

        // Play audio
        audioManager.playWordAudio(for: word, in: viewModel.section) { success in
            if !success {
                print("⚠️ Failed to play audio for '\(word.canonical)'")
            }
        }
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

            // Points earned
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
        ListeningPracticeView(section: Section(id: "test", name: "Test Section", orderIndex: 1))
    }
    .modelContainer(for: [Section.self, Word.self], inMemory: true)
}
