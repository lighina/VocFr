//
//  SpellingPracticeView.swift
//  VocFr
//
//  Created by Claude on 15/11/2025.
//  Phase C.3: Spelling Mode - Main Interface
//

import SwiftUI
import SwiftData

struct SpellingPracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SpellingViewModel
    @FocusState private var isInputFocused: Bool
    @StateObject private var audioManager = AudioPlayerManager.shared

    init(section: Section) {
        self._viewModel = State(initialValue: SpellingViewModel(section: section, modelContext: nil))
    }

    var body: some View {
        let title = String(format: "spelling.title".localized, viewModel.sectionName)

        VStack(spacing: 20) {
            if viewModel.isCompleted {
                completedView
            } else if viewModel.currentWord != nil {
                practiceView
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
            viewModel.setModelContext(modelContext)
        }
    }

    // MARK: - Practice View

    private var practiceView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress
                progressHeader

                // Image and Audio
                if let word = viewModel.currentWord {
                    imageSection(word: word)
                }

                // Hint display
                if viewModel.hintLevel > 0 {
                    hintSection
                }

                // Input section
                inputSection

                // French character toolbar
                frenchCharacterToolbar

                // Hint and Submit buttons
                actionButtons

                // Result feedback
                if viewModel.hasSubmitted, let result = viewModel.lastResult {
                    resultFeedback(result: result)
                }
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: isInputFocused ? 4 : 8) {
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

            if !isInputFocused {
                // Progress text - hide when keyboard is open
                HStack {
                    Text("spelling.progress".localized)
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
        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
    }

    // MARK: - Image Section

    private func imageSection(word: Word) -> some View {
        HStack(spacing: 16) {
            // Image - compact when keyboard is open or after submitted
            if let image = UIImage(named: word.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: isInputFocused || viewModel.hasSubmitted ? 100 : 180,
                           height: isInputFocused || viewModel.hasSubmitted ? 80 : 150)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    .animation(.easeInOut(duration: 0.3), value: isInputFocused)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.hasSubmitted)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 50))
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(width: 100, height: 80)
            }

            VStack(spacing: 12) {
                // Audio button - icon only
                Button(action: {
                    playAudio(for: word)
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                }

                if viewModel.hasSubmitted {
                    // Show only French word when submitted
                    Text(word.canonical)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, isInputFocused ? 4 : 8)
        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
    }

    // MARK: - Hint Section

    private var hintSection: some View {
        VStack(spacing: isInputFocused ? 4 : 8) {
            if !isInputFocused {
                Text("spelling.hint".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(viewModel.hintText)
                .font(isInputFocused ? .body : .title3)
                .fontWeight(.medium)
                .foregroundColor(.orange)
                .padding(isInputFocused ? 8 : 12)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: isInputFocused ? 4 : 8) {
            if !isInputFocused {
                Text("spelling.type.word".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            TextField("", text: $viewModel.userInput)
                .textFieldStyle(.roundedBorder)
                .font(isInputFocused ? .title3 : .title2)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isInputFocused)
                .disabled(viewModel.hasSubmitted)
                .submitLabel(.done)
                .onSubmit {
                    // Dismiss keyboard when user presses Done
                    isInputFocused = false
                }
                .padding(isInputFocused ? 8 : 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.cardBackground)
                )
        }
        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
    }

    // MARK: - French Character Toolbar

    private var frenchCharacterToolbar: some View {
        VStack(spacing: isInputFocused ? 4 : 8) {
            if !isInputFocused {
                Text("spelling.special.chars".localized)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Row 1: à â é è ê ë î
            HStack(spacing: isInputFocused ? 4 : 8) {
                ForEach(["à", "â", "é", "è", "ê", "ë", "î"], id: \.self) { char in
                    characterButton(char)
                }
            }

            // Row 2: ï ô ù û ç œ
            HStack(spacing: isInputFocused ? 4 : 8) {
                ForEach(["ï", "ô", "ù", "û", "ç", "œ"], id: \.self) { char in
                    characterButton(char)
                }
            }
        }
        .padding(.vertical, isInputFocused ? 4 : 8)
        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
    }

    private func characterButton(_ character: String) -> some View {
        Button(action: {
            viewModel.userInput += character
            // Keep focus on input field after adding character
            isInputFocused = true
        }) {
            Text(character)
                .font(isInputFocused ? .body : .headline)
                .foregroundColor(.specialCharForeground)
                .frame(width: isInputFocused ? 30 : 35, height: isInputFocused ? 30 : 35)
                .background(Color.specialCharBackground)
                .cornerRadius(6)
        }
        .disabled(viewModel.hasSubmitted)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: isInputFocused ? 8 : 16) {
            // Hint button
            if !viewModel.hasSubmitted {
                Button(action: {
                    viewModel.requestHint()
                }) {
                    HStack(spacing: isInputFocused ? 4 : 8) {
                        Image(systemName: "lightbulb.fill")
                        if !isInputFocused {
                            Text("spelling.hint.button".localized)
                        }
                    }
                    .font(isInputFocused ? .body : .headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(isInputFocused ? 10 : 12)
                    .background(Color.orange)
                    .cornerRadius(12)
                }
                .disabled(viewModel.hintLevel >= 4)
                .opacity(viewModel.hintLevel >= 4 ? 0.5 : 1.0)
            }

            // Submit or Next button
            if viewModel.hasSubmitted {
                Button(action: {
                    withAnimation {
                        viewModel.nextWord()
                    }
                }) {
                    HStack {
                        Text("spelling.next".localized)
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
            } else {
                Button(action: {
                    viewModel.submitAnswer()
                    isInputFocused = false
                }) {
                    HStack(spacing: isInputFocused ? 4 : 8) {
                        Image(systemName: "checkmark.circle.fill")
                        if !isInputFocused {
                            Text("spelling.check".localized)
                        }
                    }
                    .font(isInputFocused ? .body : .headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(isInputFocused ? 10 : 12)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                .disabled(viewModel.userInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isInputFocused)
    }

    // MARK: - Result Feedback

    private func resultFeedback(result: SpellingResult) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                resultIcon(for: result)
                resultText(for: result)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(resultColor(for: result).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(resultColor(for: result).opacity(0.3), lineWidth: 2)
                    )
            )

            // Show correct answer if wrong
            if case .incorrect = result, let word = viewModel.currentWord {
                VStack(spacing: 4) {
                    Text("spelling.correct.answer".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(word.canonical)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .transition(.scale.combined(with: .opacity))
    }

    private func resultIcon(for result: SpellingResult) -> some View {
        Group {
            switch result {
            case .correct:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .correctWithCase:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            case .missingAccents:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            case .wrongAccents:
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.red)
            case .closeMatch:
                Image(systemName: "xmark.circle")
                    .foregroundColor(.orange)
            case .incorrect:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .font(.title)
    }

    private func resultText(for result: SpellingResult) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            switch result {
            case .correct:
                Text("spelling.result.correct".localized)
                    .font(.headline)
                    .foregroundColor(.green)
            case .correctWithCase:
                Text("spelling.result.case".localized)
                    .font(.headline)
                    .foregroundColor(.green)
            case .missingAccents:
                Text("spelling.result.missing.accents".localized)
                    .font(.headline)
                    .foregroundColor(.orange)
                Text("spelling.result.missing.accents.detail".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .wrongAccents:
                Text("spelling.result.wrong.accents".localized)
                    .font(.headline)
                    .foregroundColor(.red)
                Text("spelling.result.wrong.accents.detail".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .closeMatch(let distance):
                Text("spelling.result.close".localized)
                    .font(.headline)
                    .foregroundColor(.orange)
                Text(String(format: "spelling.result.close.detail".localized, distance))
                    .font(.caption)
                    .foregroundColor(.secondary)
            case .incorrect:
                Text("spelling.result.incorrect".localized)
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
    }

    private func resultColor(for result: SpellingResult) -> Color {
        switch result {
        case .correct, .correctWithCase:
            return .green
        case .missingAccents, .closeMatch:
            return .orange
        case .wrongAccents, .incorrect:
            return .red
        }
    }

    // MARK: - Completed View

    private var completedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("spelling.completed.title".localized)
                .font(.largeTitle)
                .fontWeight(.bold)

            // Statistics
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "character.cursor.ibeam")
                        .foregroundColor(.blue)
                    Text("spelling.words.practiced".localized)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.totalPracticed)")
                        .fontWeight(.semibold)
                }

                Divider()

                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("spelling.correct.count".localized)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(viewModel.correctCount)")
                        .fontWeight(.semibold)
                }

                Divider()

                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.green)
                    Text("spelling.accuracy".localized)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(viewModel.accuracy * 100))%")
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
            )

            // Restart button
            Button(action: {
                withAnimation {
                    viewModel.restart()
                }
            }) {
                Text("spelling.restart".localized)
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

            Image(systemName: "text.cursor")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("spelling.empty.title".localized)
                .font(.title2)
                .fontWeight(.semibold)

            Text("spelling.empty.message".localized)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Audio Playback

    private func playAudio(for word: Word) {
        audioManager.playWordAudio(for: word, in: viewModel.section) { success in
            if success {
                print("🔊 Playing audio for: \(word.canonical)")
            } else {
                print("⚠️ No audio available for: \(word.canonical)")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let schema = Schema([Section.self, Word.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    return NavigationView {
        SpellingPracticeView(section: Section(id: "test", name: "Test Section", orderIndex: 1))
    }
    .modelContainer(container)
}
