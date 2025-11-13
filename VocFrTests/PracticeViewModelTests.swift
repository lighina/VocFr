//
//  PracticeViewModelTests.swift
//  VocFrTests
//
//  Created by Claude on 13/11/2025.
//  Phase 3.1: MVVM Architecture Refactoring - Unit Tests
//

import XCTest
import SwiftData
@testable import VocFr

/// Unit tests for PracticeViewModel
/// Tests business logic independently of UI
final class PracticeViewModelTests: XCTestCase {

    var testSection: Section!
    var testWords: [Word]!

    override func setUp() {
        super.setUp()

        // Create test section
        testSection = Section(id: "test_section", name: "Test Section", orderIndex: 1)

        // Create test words
        let word1 = Word(
            id: "word1-noun",
            canonical: "bureau",
            chinese: "课桌",
            imageName: "bureau_image",
            partOfSpeech: .noun,
            category: "school"
        )

        let word2 = Word(
            id: "word2-noun",
            canonical: "table",
            chinese: "桌子",
            imageName: "table_image",
            partOfSpeech: .noun,
            category: "school"
        )

        let word3 = Word(
            id: "word3-noun",
            canonical: "chaise",
            chinese: "椅子",
            imageName: "chaise_image",
            partOfSpeech: .noun,
            category: "school"
        )

        testWords = [word1, word2, word3]

        // Link words to section
        for (index, word) in testWords.enumerated() {
            let sectionWord = SectionWord(orderIndex: index)
            sectionWord.word = word
            sectionWord.section = testSection
            testSection.sectionWords.append(sectionWord)
        }
    }

    override func tearDown() {
        testSection = nil
        testWords = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertEqual(viewModel.currentWordIndex, 0)
        XCTAssertFalse(viewModel.showAnswer)
        XCTAssertEqual(viewModel.correctCount, 0)
        XCTAssertFalse(viewModel.isCompleted)
    }

    func testWordsProperty() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertEqual(viewModel.words.count, 3)
        XCTAssertEqual(viewModel.words[0].canonical, "bureau")
        XCTAssertEqual(viewModel.words[1].canonical, "table")
        XCTAssertEqual(viewModel.words[2].canonical, "chaise")
    }

    func testCurrentWord() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertEqual(viewModel.currentWord?.canonical, "bureau")
    }

    // MARK: - Action Tests

    func testShowAnswer() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertFalse(viewModel.showAnswer)

        viewModel.showAnswerAction()

        XCTAssertTrue(viewModel.showAnswer)
    }

    func testMarkCorrect() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        viewModel.showAnswerAction()
        viewModel.markCorrect()

        XCTAssertEqual(viewModel.correctCount, 1)
        XCTAssertEqual(viewModel.currentWordIndex, 1)
        XCTAssertFalse(viewModel.showAnswer)
        XCTAssertEqual(viewModel.currentWord?.canonical, "table")
    }

    func testMarkIncorrect() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        viewModel.showAnswerAction()
        viewModel.markIncorrect()

        XCTAssertEqual(viewModel.correctCount, 0)
        XCTAssertEqual(viewModel.currentWordIndex, 1)
        XCTAssertFalse(viewModel.showAnswer)
        XCTAssertEqual(viewModel.currentWord?.canonical, "table")
    }

    func testPracticeFlow() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        // First word - correct
        viewModel.showAnswerAction()
        XCTAssertTrue(viewModel.showAnswer)
        viewModel.markCorrect()

        // Second word - incorrect
        XCTAssertFalse(viewModel.showAnswer)
        viewModel.showAnswerAction()
        viewModel.markIncorrect()

        // Third word - correct
        viewModel.showAnswerAction()
        viewModel.markCorrect()

        // Should be completed
        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertEqual(viewModel.correctCount, 2)
        XCTAssertEqual(viewModel.currentWordIndex, 3)
    }

    func testRestartPractice() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        // Complete a practice session
        viewModel.markCorrect()
        viewModel.markCorrect()
        viewModel.markCorrect()

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertEqual(viewModel.correctCount, 3)

        // Restart
        viewModel.restartPractice()

        XCTAssertEqual(viewModel.currentWordIndex, 0)
        XCTAssertFalse(viewModel.showAnswer)
        XCTAssertEqual(viewModel.correctCount, 0)
        XCTAssertFalse(viewModel.isCompleted)
        XCTAssertEqual(viewModel.currentWord?.canonical, "bureau")
    }

    // MARK: - Computed Property Tests

    func testProgressText() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertEqual(viewModel.progressText, "1 / 3")

        viewModel.markCorrect()
        XCTAssertEqual(viewModel.progressText, "2 / 3")

        viewModel.markIncorrect()
        XCTAssertEqual(viewModel.progressText, "3 / 3")
    }

    func testCorrectCountText() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertEqual(viewModel.correctCountText, "正确: 0")

        viewModel.markCorrect()
        XCTAssertEqual(viewModel.correctCountText, "正确: 1")

        viewModel.markIncorrect()
        XCTAssertEqual(viewModel.correctCountText, "正确: 1")

        viewModel.markCorrect()
        XCTAssertEqual(viewModel.correctCountText, "正确: 2")
    }

    func testAccuracyPercentage() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        viewModel.markCorrect()  // 1/3 = 33%
        viewModel.markIncorrect() // 1/3 = 33%
        viewModel.markCorrect()  // 2/3 = 66%

        XCTAssertEqual(viewModel.accuracyPercentage, 66)
    }

    func testAccuracyText() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        viewModel.markCorrect()
        viewModel.markCorrect()
        viewModel.markCorrect()

        XCTAssertEqual(viewModel.accuracyText, "正确率: 100%")
    }

    func testResultsSummaryText() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        viewModel.markCorrect()
        viewModel.markIncorrect()
        viewModel.markCorrect()

        XCTAssertEqual(viewModel.resultsSummaryText, "答对 2 / 3 个单词")
    }

    func testTotalWords() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertEqual(viewModel.totalWords, 3)
    }

    func testSectionName() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        XCTAssertEqual(viewModel.sectionName, "Test Section")
    }

    // MARK: - Edge Case Tests

    func testEmptySection() {
        let emptySection = Section(id: "empty", name: "Empty", orderIndex: 1)
        let viewModel = PracticeViewModel(section: emptySection, modelContext: nil)

        XCTAssertEqual(viewModel.totalWords, 0)
        XCTAssertNil(viewModel.currentWord)
        XCTAssertEqual(viewModel.progressText, "1 / 0")
        XCTAssertEqual(viewModel.accuracyPercentage, 0)
    }

    func testAllCorrect() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        viewModel.markCorrect()
        viewModel.markCorrect()
        viewModel.markCorrect()

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertEqual(viewModel.accuracyPercentage, 100)
        XCTAssertEqual(viewModel.correctCount, 3)
    }

    func testAllIncorrect() {
        let viewModel = PracticeViewModel(section: testSection, modelContext: nil)

        viewModel.markIncorrect()
        viewModel.markIncorrect()
        viewModel.markIncorrect()

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertEqual(viewModel.accuracyPercentage, 0)
        XCTAssertEqual(viewModel.correctCount, 0)
    }
}
