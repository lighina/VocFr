//
//  TestModels.swift
//  VocFr
//
//  Created by Claude on 16/11/2025.
//  Test mode models and data structures
//

import Foundation
import SwiftData

// MARK: - Question Type

enum TestQuestionType: String, Codable {
    case imageToWord      // 看图选词
    case audioToWord      // 听音辨词
    case spelling         // 拼写题
    case genderGuess      // 名词性别判断
}

// MARK: - Test Question

struct TestQuestion: Identifiable {
    let id: String
    let type: TestQuestionType
    let word: Word
    let options: [String]       // For multiple choice questions
    let correctAnswer: String

    init(id: String = UUID().uuidString, type: TestQuestionType, word: Word, options: [String], correctAnswer: String) {
        self.id = id
        self.type = type
        self.word = word
        self.options = options
        self.correctAnswer = correctAnswer
    }
}

// MARK: - Question Result

struct QuestionResult: Codable {
    let questionId: String
    let questionType: TestQuestionType
    let wordId: String
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
}

// MARK: - Test Result

struct TestResult {
    let score: Int                          // 总分
    let totalQuestions: Int                 // 总题数
    let correctAnswers: Int                 // 正确题数
    let timeSpent: TimeInterval             // 总用时
    let questionResults: [QuestionResult]   // 每题详情

    // 按题型统计
    var imageToWordCorrect: Int {
        questionResults.filter { $0.questionType == .imageToWord && $0.isCorrect }.count
    }
    var imageToWordTotal: Int {
        questionResults.filter { $0.questionType == .imageToWord }.count
    }

    var audioToWordCorrect: Int {
        questionResults.filter { $0.questionType == .audioToWord && $0.isCorrect }.count
    }
    var audioToWordTotal: Int {
        questionResults.filter { $0.questionType == .audioToWord }.count
    }

    var spellingCorrect: Int {
        questionResults.filter { $0.questionType == .spelling && $0.isCorrect }.count
    }
    var spellingTotal: Int {
        questionResults.filter { $0.questionType == .spelling }.count
    }

    var genderGuessCorrect: Int {
        questionResults.filter { $0.questionType == .genderGuess && $0.isCorrect }.count
    }
    var genderGuessTotal: Int {
        questionResults.filter { $0.questionType == .genderGuess }.count
    }

    // 星级评定
    var starRating: Int {
        if score >= 90 { return 3 }
        if score >= 75 { return 2 }
        if score >= 60 { return 1 }
        return 0
    }

    var ratingText: String {
        switch starRating {
        case 3: return "test.rating.excellent".localized
        case 2: return "test.rating.good".localized
        case 1: return "test.rating.pass".localized
        default: return "test.rating.needsReview".localized
        }
    }
}

// MARK: - Test Record (SwiftData)

@Model
final class TestRecord {
    var id: String
    var date: Date
    var uniteId: String?            // nil表示综合测试
    var uniteNumber: Int?
    var score: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var timeSpent: TimeInterval
    var questionResultsData: Data?  // JSON encoded [QuestionResult]

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        uniteId: String? = nil,
        uniteNumber: Int? = nil,
        score: Int,
        totalQuestions: Int,
        correctAnswers: Int,
        timeSpent: TimeInterval,
        questionResults: [QuestionResult]
    ) {
        self.id = id
        self.date = date
        self.uniteId = uniteId
        self.uniteNumber = uniteNumber
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.timeSpent = timeSpent

        // Encode question results to JSON
        if let data = try? JSONEncoder().encode(questionResults) {
            self.questionResultsData = data
        }
    }

    var questionResults: [QuestionResult] {
        guard let data = questionResultsData,
              let results = try? JSONDecoder().decode([QuestionResult].self, from: data) else {
            return []
        }
        return results
    }
}

// MARK: - Wrong Answer Record (for错题本)

@Model
final class WrongAnswerRecord {
    var id: String
    var wordId: String
    var questionType: String        // TestQuestionType.rawValue
    var userAnswer: String
    var correctAnswer: String
    var firstWrongDate: Date
    var lastWrongDate: Date
    var wrongCount: Int
    var isRetried: Bool             // 是否已重做
    var isMastered: Bool            // 是否已掌握

    init(
        id: String = UUID().uuidString,
        wordId: String,
        questionType: TestQuestionType,
        userAnswer: String,
        correctAnswer: String,
        firstWrongDate: Date = Date(),
        lastWrongDate: Date = Date(),
        wrongCount: Int = 1,
        isRetried: Bool = false,
        isMastered: Bool = false
    ) {
        self.id = id
        self.wordId = wordId
        self.questionType = questionType.rawValue
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.firstWrongDate = firstWrongDate
        self.lastWrongDate = lastWrongDate
        self.wrongCount = wrongCount
        self.isRetried = isRetried
        self.isMastered = isMastered
    }
}
