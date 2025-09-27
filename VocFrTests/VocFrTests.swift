//
//  VocFrTests.swift
//  VocFrTests
//
//  Created by Junfeng Wang on 22/09/2025.
//

import Testing
import SwiftData
@testable import VocFr

struct VocFrTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

@Suite("French Vocabulary Model Tests")
struct FrenchVocabularyTests {
    
    @Test("Data model creation")
    func testDataModelCreation() async throws {
        // Test creating basic models
        let unite = Unite(
            id: "test_unite",
            number: 1,
            title: "Test Unit",
            isUnlocked: true,
            requiredStars: 0
        )
        
        #expect(unite.id == "test_unite")
        #expect(unite.number == 1)
        #expect(unite.title == "Test Unit")
        #expect(unite.isUnlocked == true)
        #expect(unite.requiredStars == 0)
    }
    
    @Test("Word form creation")
    func testWordFormCreation() async throws {
        let wordForm = WordForm(
            formType: .indefiniteArticle,
            french: "un livre",
            articleOnly: "un",
            gender: .masculine,
            number: .singular,
            isMainForm: true
        )
        
        #expect(wordForm.formType == .indefiniteArticle)
        #expect(wordForm.french == "un livre")
        #expect(wordForm.articleOnly == "un")
        #expect(wordForm.gender == .masculine)
        #expect(wordForm.number == .singular)
        #expect(wordForm.isMainForm == true)
    }
    
    @Test("Word creation")
    func testWordCreation() async throws {
        let word = Word(
            id: "livre",
            canonical: "livre",
            chinese: "书",
            imageName: "livre_image",
            partOfSpeech: .noun,
            category: "school_objects"
        )
        
        let form = WordForm(
            formType: .indefiniteArticle,
            french: "un livre",
            articleOnly: "un",
            gender: .masculine,
            number: .singular,
            isMainForm: true
        )
        
        word.forms = [form]
        
        #expect(word.id == "livre")
        #expect(word.canonical == "livre")
        #expect(word.chinese == "书")
        #expect(word.partOfSpeech == .noun)
        #expect(word.forms.count == 1)
        #expect(word.forms.first?.isMainForm == true)
    }
    
    @Test("Audio segment creation")
    func testAudioSegmentCreation() async throws {
        let audioSegment = AudioSegment(
            startTime: 0.0,
            endTime: 1.2,
            formType: .indefiniteArticle,
            quality: .normal,
            confidence: 0.9
        )
        
        #expect(audioSegment.startTime == 0.0)
        #expect(audioSegment.endTime == 1.2)
        #expect(audioSegment.formType == .indefiniteArticle)
        #expect(audioSegment.quality == .normal)
        #expect(abs(audioSegment.confidence - 0.9) < 0.001)
    }
}
