//
//  TestViewModel.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Test mode view model
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class TestViewModel {
    // MARK: - Properties

    let unite: Unite?               // nil = comprehensive test
    private let modelContext: ModelContext?

    var questions: [TestQuestion] = []
    var currentIndex: Int = 0
    var answers: [String: String] = [:]     // questionId: userAnswer
    var questionStartTimes: [String: Date] = [:]
    var startTime: Date = Date()
    var timeLimit: TimeInterval = 600       // 10 minutes
    var elapsedTime: TimeInterval = 0

    private var timer: Timer?

    // MARK: - Computed Properties

    var currentQuestion: TestQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentIndex) / Double(questions.count)
    }

    var progressText: String {
        "\(currentIndex + 1) / \(questions.count)"
    }

    var formattedTime: String {
        let remaining = max(0, timeLimit - elapsedTime)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var isTimeUp: Bool {
        elapsedTime >= timeLimit
    }

    var canGoBack: Bool {
        currentIndex > 0
    }

    var canGoNext: Bool {
        currentIndex < questions.count - 1
    }

    var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }

    var hasAnsweredCurrent: Bool {
        guard let question = currentQuestion else { return false }
        return answers[question.id] != nil
    }

    // MARK: - Initialization

    init(unite: Unite?, modelContext: ModelContext?) {
        self.unite = unite
        self.modelContext = modelContext
        setupQuestions()
    }

    // MARK: - Setup

    private func setupQuestions() {
        // Collect words from unite or all unites
        var words: [Word] = []

        if let unite = unite {
            // Single unite test
            for section in unite.sections {
                for sectionWord in section.sectionWords {
                    if let word = sectionWord.word, word.partOfSpeech != .other {
                        words.append(word)
                    }
                }
            }
        } else {
            // Comprehensive test - need access to all unites
            // This will be set from the view
        }

        // Filter words
        words = words.filter { $0.partOfSpeech != .other }

        // Shuffle words
        words.shuffle()

        // Generate 20 questions (5 of each type)
        var generatedQuestions: [TestQuestion] = []

        // 1. Image to Word (5 questions)
        let imageWords = words.shuffled().prefix(5)
        for word in imageWords {
            if let question = generateImageToWordQuestion(word: word, allWords: words) {
                generatedQuestions.append(question)
            }
        }

        // 2. Audio to Word (5 questions)
        let audioWords = words.shuffled().prefix(5)
        for word in audioWords {
            if let question = generateAudioToWordQuestion(word: word, allWords: words) {
                generatedQuestions.append(question)
            }
        }

        // 3. Spelling (5 questions)
        let spellingWords = words.shuffled().prefix(5)
        for word in spellingWords {
            generatedQuestions.append(generateSpellingQuestion(word: word))
        }

        // 4. Gender Guess (5 questions) - only nouns
        let nounWords = words.filter { $0.partOfSpeech == .noun }.shuffled().prefix(5)
        for word in nounWords {
            generatedQuestions.append(generateGenderQuestion(word: word))
        }

        // Shuffle all questions
        questions = generatedQuestions.shuffled()
    }

    func setAllWords(_ words: [Word]) {
        if unite == nil {
            // This is a comprehensive test
            var filteredWords = words.filter { $0.partOfSpeech != .other }
            filteredWords.shuffle()

            var generatedQuestions: [TestQuestion] = []

            // Generate questions using all words
            let imageWords = filteredWords.shuffled().prefix(5)
            for word in imageWords {
                if let question = generateImageToWordQuestion(word: word, allWords: filteredWords) {
                    generatedQuestions.append(question)
                }
            }

            let audioWords = filteredWords.shuffled().prefix(5)
            for word in audioWords {
                if let question = generateAudioToWordQuestion(word: word, allWords: filteredWords) {
                    generatedQuestions.append(question)
                }
            }

            let spellingWords = filteredWords.shuffled().prefix(5)
            for word in spellingWords {
                generatedQuestions.append(generateSpellingQuestion(word: word))
            }

            let nounWords = filteredWords.filter { $0.partOfSpeech == .noun }.shuffled().prefix(5)
            for word in nounWords {
                generatedQuestions.append(generateGenderQuestion(word: word))
            }

            questions = generatedQuestions.shuffled()
        }
    }

    // MARK: - Question Generation

    private func generateImageToWordQuestion(word: Word, allWords: [Word]) -> TestQuestion? {
        // Generate 3 wrong options
        var options: [String] = [word.canonical]

        let wrongWords = allWords
            .filter { $0.id != word.id && $0.partOfSpeech == word.partOfSpeech }
            .shuffled()
            .prefix(3)

        options.append(contentsOf: wrongWords.map { $0.canonical })
        options.shuffle()

        guard options.count == 4 else { return nil }

        return TestQuestion(
            type: .imageToWord,
            word: word,
            options: options,
            correctAnswer: word.canonical
        )
    }

    private func generateAudioToWordQuestion(word: Word, allWords: [Word]) -> TestQuestion? {
        // Similar to image to word
        var options: [String] = [word.canonical]

        let wrongWords = allWords
            .filter { $0.id != word.id && $0.partOfSpeech == word.partOfSpeech }
            .shuffled()
            .prefix(3)

        options.append(contentsOf: wrongWords.map { $0.canonical })
        options.shuffle()

        guard options.count == 4 else { return nil }

        return TestQuestion(
            type: .audioToWord,
            word: word,
            options: options,
            correctAnswer: word.canonical
        )
    }

    private func generateSpellingQuestion(word: Word) -> TestQuestion {
        TestQuestion(
            type: .spelling,
            word: word,
            options: [],
            correctAnswer: word.canonical.lowercased()
        )
    }

    private func generateGenderQuestion(word: Word) -> TestQuestion {
        // For nouns, determine gender from article
        let correctGender: String
        if word.canonical.lowercased().hasPrefix("le ") {
            correctGender = "masculine"
        } else if word.canonical.lowercased().hasPrefix("la ") {
            correctGender = "feminine"
        } else if word.canonical.lowercased().hasPrefix("l'") {
            // Default to masculine for l' words (could be improved)
            correctGender = "masculine"
        } else {
            correctGender = "masculine"
        }

        return TestQuestion(
            type: .genderGuess,
            word: word,
            options: ["masculine", "feminine"],
            correctAnswer: correctGender
        )
    }

    // MARK: - Actions

    func startTest() {
        startTime = Date()
        if let first = questions.first {
            questionStartTimes[first.id] = Date()
        }
        startTimer()
    }

    func submitAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        answers[question.id] = answer
    }

    func nextQuestion() {
        guard canGoNext else { return }
        currentIndex += 1
        if let question = currentQuestion {
            questionStartTimes[question.id] = Date()
        }
    }

    func previousQuestion() {
        guard canGoBack else { return }
        currentIndex -= 1
    }

    func finishTest() -> TestResult {
        stopTimer()

        let endTime = Date()
        let totalTime = endTime.timeIntervalSince(startTime)

        var questionResults: [QuestionResult] = []
        var correctCount = 0

        for question in questions {
            let userAnswer = answers[question.id] ?? ""
            let isCorrect: Bool

            if question.type == .spelling {
                // Case-insensitive comparison for spelling
                isCorrect = userAnswer.lowercased() == question.correctAnswer.lowercased()
            } else {
                isCorrect = userAnswer == question.correctAnswer
            }

            if isCorrect {
                correctCount += 1
            }

            let questionTime = questionStartTimes[question.id] ?? startTime
            let timeDiff = min(30.0, Date().timeIntervalSince(questionTime))

            let result = QuestionResult(
                questionId: question.id,
                questionType: question.type,
                wordId: question.word.id,
                userAnswer: userAnswer,
                correctAnswer: question.correctAnswer,
                isCorrect: isCorrect,
                timeSpent: timeDiff
            )

            questionResults.append(result)

            // Save wrong answers to wrong answer book
            if !isCorrect {
                saveWrongAnswer(question: question, userAnswer: userAnswer)
            }
        }

        let score = Int(Double(correctCount) / Double(questions.count) * 100)

        let result = TestResult(
            score: score,
            totalQuestions: questions.count,
            correctAnswers: correctCount,
            timeSpent: totalTime,
            questionResults: questionResults
        )

        // Save test record
        saveTestRecord(result: result)

        return result
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Persistence

    private func saveTestRecord(result: TestResult) {
        guard let modelContext = modelContext else { return }

        let record = TestRecord(
            uniteId: unite?.id,
            uniteNumber: unite?.number,
            score: result.score,
            totalQuestions: result.totalQuestions,
            correctAnswers: result.correctAnswers,
            timeSpent: result.timeSpent,
            questionResults: result.questionResults
        )

        modelContext.insert(record)

        do {
            try modelContext.save()
            print("✅ Test record saved")

            // Award stars based on performance
            let stars = result.score / 10
            if stars > 0 {
                PointsManager.shared.awardStars(
                    points: stars,
                    modelContext: modelContext,
                    reason: "Test completed with score \(result.score)"
                )
            }
        } catch {
            print("❌ Failed to save test record: \(error)")
        }
    }

    private func saveWrongAnswer(question: TestQuestion, userAnswer: String) {
        guard let modelContext = modelContext else { return }

        // Check if this word already has a wrong answer record
        let descriptor = FetchDescriptor<WrongAnswerRecord>(
            predicate: #Predicate { record in
                record.wordId == question.word.id &&
                record.questionType == question.type.rawValue
            }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            // Update existing record
            existing.lastWrongDate = Date()
            existing.wrongCount += 1
            existing.userAnswer = userAnswer
        } else {
            // Create new record
            let record = WrongAnswerRecord(
                wordId: question.word.id,
                questionType: question.type,
                userAnswer: userAnswer,
                correctAnswer: question.correctAnswer
            )
            modelContext.insert(record)
        }

        try? modelContext.save()
    }

    deinit {
        stopTimer()
    }
}
