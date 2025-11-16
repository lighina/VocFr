//
//  TestSessionView.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Test session view - answering questions
//

import SwiftUI
import SwiftData
import AVFoundation

struct TestSessionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: TestViewModel
    @State private var hasInitialized = false
    @State private var showingResult = false
    @State private var testResult: TestResult?
    @State private var selectedAnswer: String = ""
    @State private var spellingInput: String = ""

    let unite: Unite?
    let allWords: [Word]

    init(unite: Unite?, allWords: [Word]) {
        self.unite = unite
        self.allWords = allWords
        self._viewModel = State(initialValue: TestViewModel(unite: unite, modelContext: nil))
    }

    var body: some View {
        VStack(spacing: 0) {
            if showingResult, let result = testResult {
                TestResultView(result: result, unite: unite) {
                    dismiss()
                }
            } else {
                testView
            }
        }
        .navigationTitle(unite?.title ?? "test.comprehensive".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("test.button.back".localized)
                    }
                }
            }
        }
        .onAppear {
            if !hasInitialized {
                viewModel = TestViewModel(unite: unite, modelContext: modelContext)
                if unite == nil {
                    viewModel.setAllWords(allWords)
                }
                viewModel.startTest()
                hasInitialized = true
            }
        }
    }

    // MARK: - Test View

    private var testView: some View {
        VStack(spacing: 0) {
            // Progress Bar
            progressHeader

            ScrollView {
                VStack(spacing: 20) {
                    if let question = viewModel.currentQuestion {
                        // Question Content
                        questionView(question: question)

                        // Answer Options
                        answerView(question: question)
                    }

                    Spacer(minLength: 20)
                }
                .padding()
            }

            // Navigation Buttons
            navigationButtons
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text(viewModel.progressText)
                    .font(.headline)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(viewModel.formattedTime)
                        .font(.system(.headline, design: .monospaced))
                }
                .foregroundColor(viewModel.elapsedTime > 540 ? .red : .primary)
            }

            ProgressView(value: viewModel.progress, total: 1.0)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemGray6))
    }

    // MARK: - Question View

    @ViewBuilder
    private func questionView(question: TestQuestion) -> some View {
        VStack(spacing: 16) {
            // Question Type Label
            Text(questionTypeText(question.type))
                .font(.subheadline)
                .foregroundColor(.secondary)

            switch question.type {
            case .imageToWord:
                imageQuestionView(word: question.word)

            case .audioToWord:
                audioQuestionView(word: question.word)

            case .spelling:
                spellingQuestionView(word: question.word)

            case .genderGuess:
                genderQuestionView(word: question.word)
            }
        }
    }

    private func imageQuestionView(word: Word) -> some View {
        VStack(spacing: 12) {
            if !word.imageName.isEmpty {
                Image(word.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .cornerRadius(12)
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 80))
                    .foregroundColor(.gray)
                    .frame(height: 200)
            }
        }
    }

    private func audioQuestionView(word: Word) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "speaker.wave.3.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Button(action: {
                AudioPlayerManager.shared.playWordAudio(for: word) { _ in }
            }) {
                HStack {
                    Image(systemName: "play.circle.fill")
                    Text("test.button.listen".localized)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
    }

    private func spellingQuestionView(word: Word) -> some View {
        VStack(spacing: 12) {
            // Show image or play audio
            if !word.imageName.isEmpty {
                Image(word.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                    .cornerRadius(12)
            }

            Button(action: {
                AudioPlayerManager.shared.playWordAudio(for: word) { _ in }
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2")
                    Text("test.button.listen".localized)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
    }

    private func genderQuestionView(word: Word) -> some View {
        VStack(spacing: 12) {
            Text(word.canonical)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
        }
    }

    // MARK: - Answer View

    @ViewBuilder
    private func answerView(question: TestQuestion) -> some View {
        VStack(spacing: 16) {
            switch question.type {
            case .imageToWord, .audioToWord:
                multipleChoiceView(question: question)

            case .spelling:
                spellingInputView(question: question)

            case .genderGuess:
                genderChoiceView(question: question)
            }
        }
    }

    private func multipleChoiceView(question: TestQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    selectedAnswer = option
                    viewModel.submitAnswer(option)
                }) {
                    HStack {
                        Text(option)
                            .font(.body)
                            .foregroundColor(.primary)

                        Spacer()

                        if selectedAnswer == option {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(selectedAnswer == option ? Color.blue.opacity(0.1) : Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(selectedAnswer == option ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func spellingInputView(question: TestQuestion) -> some View {
        VStack(spacing: 12) {
            TextField("test.question.spelling".localized, text: $spellingInput)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.title3)
                .multilineTextAlignment(.center)
                .onChange(of: spellingInput) { _, newValue in
                    selectedAnswer = newValue
                    viewModel.submitAnswer(newValue)
                }
        }
    }

    private func genderChoiceView(question: TestQuestion) -> some View {
        HStack(spacing: 16) {
            Button(action: {
                selectedAnswer = "masculine"
                viewModel.submitAnswer("masculine")
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "m.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)

                    Text("test.gender.masculine".localized)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedAnswer == "masculine" ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedAnswer == "masculine" ? Color.blue : Color.clear, lineWidth: 2)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                selectedAnswer = "feminine"
                viewModel.submitAnswer("feminine")
            }) {
                VStack(spacing: 8) {
                    Image(systemName: "f.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.pink)

                    Text("test.gender.feminine".localized)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(selectedAnswer == "feminine" ? Color.pink.opacity(0.1) : Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(selectedAnswer == "feminine" ? Color.pink : Color.clear, lineWidth: 2)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if viewModel.canGoBack {
                Button(action: {
                    viewModel.previousQuestion()
                    loadCurrentAnswer()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("test.button.previous".localized)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                }
            }

            if viewModel.isLastQuestion {
                Button(action: finishTest) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("test.button.finish".localized)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!viewModel.hasAnsweredCurrent)
            } else {
                Button(action: {
                    viewModel.nextQuestion()
                    loadCurrentAnswer()
                }) {
                    HStack {
                        Text("test.button.next".localized)
                        Image(systemName: "chevron.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.hasAnsweredCurrent ? Color.blue : Color(.systemGray5))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!viewModel.hasAnsweredCurrent)
            }
        }
        .padding()
    }

    // MARK: - Helpers

    private func questionTypeText(_ type: TestQuestionType) -> String {
        switch type {
        case .imageToWord:
            return "test.question.imageToWord".localized
        case .audioToWord:
            return "test.question.audioToWord".localized
        case .spelling:
            return "test.question.spelling".localized
        case .genderGuess:
            return "test.question.genderGuess".localized
        }
    }

    private func loadCurrentAnswer() {
        guard let question = viewModel.currentQuestion else { return }
        let answer = viewModel.answers[question.id] ?? ""
        selectedAnswer = answer

        if question.type == .spelling {
            spellingInput = answer
        }
    }

    private func finishTest() {
        let result = viewModel.finishTest()
        testResult = result
        showingResult = true
    }
}

#Preview {
    NavigationStack {
        TestSessionView(unite: nil, allWords: [])
            .modelContainer(for: [Unite.self, TestRecord.self], inMemory: true)
    }
}
