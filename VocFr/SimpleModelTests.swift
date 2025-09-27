//
//  SimpleModelTests.swift - No framework dependencies
//  Just pure Swift code to test your models
//

import SwiftData

// Simple test runner that doesn't depend on XCTest or Testing frameworks
struct SimpleModelTests {
    
    static func runAllTests() {
        print("🧪 Running French Vocabulary Model Tests...")
        
        testUniteCreation()
        testWordFormCreation() 
        testWordCreation()
        testAudioSegmentCreation()
        
        print("✅ All tests completed!")
    }
    
    static func testUniteCreation() {
        print("Testing Unite creation...")
        
        let unite = Unite(
            id: "test_unite",
            number: 1,
            title: "Test Unit",
            isUnlocked: true,
            requiredStars: 0
        )
        
        assert(unite.id == "test_unite", "Unite ID should match")
        assert(unite.number == 1, "Unite number should be 1")
        assert(unite.title == "Test Unit", "Unite title should match")
        assert(unite.isUnlocked == true, "Unite should be unlocked")
        assert(unite.requiredStars == 0, "Required stars should be 0")
        
        print("✅ Unite creation test passed")
    }
    
    static func testWordFormCreation() {
        print("Testing WordForm creation...")
        
        let wordForm = WordForm(
            formType: .indefiniteArticle,
            french: "un livre",
            articleOnly: "un",
            gender: .masculine,
            number: .singular,
            isMainForm: true
        )
        
        assert(wordForm.formType == .indefiniteArticle, "Form type should match")
        assert(wordForm.french == "un livre", "French text should match")
        assert(wordForm.articleOnly == "un", "Article should match")
        assert(wordForm.gender == .masculine, "Gender should be masculine")
        assert(wordForm.number == .singular, "Number should be singular")
        assert(wordForm.isMainForm == true, "Should be main form")
        
        print("✅ WordForm creation test passed")
    }
    
    static func testWordCreation() {
        print("Testing Word creation...")
        
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
        
        assert(word.id == "livre", "Word ID should match")
        assert(word.canonical == "livre", "Canonical form should match")
        assert(word.chinese == "书", "Chinese translation should match")
        assert(word.partOfSpeech == .noun, "Part of speech should be noun")
        assert(word.forms.count == 1, "Should have one form")
        assert(word.forms.first?.isMainForm == true, "First form should be main form")
        
        print("✅ Word creation test passed")
    }
    
    static func testAudioSegmentCreation() {
        print("Testing AudioSegment creation...")
        
        let audioSegment = AudioSegment(
            startTime: 0.0,
            endTime: 1.2,
            formType: .indefiniteArticle,
            quality: .normal,
            confidence: 0.9
        )
        
        assert(audioSegment.startTime == 0.0, "Start time should match")
        assert(audioSegment.endTime == 1.2, "End time should match") 
        assert(audioSegment.formType == .indefiniteArticle, "Form type should match")
        assert(audioSegment.quality == .normal, "Quality should be normal")
        assert(abs(audioSegment.confidence - 0.9) < 0.001, "Confidence should be close to 0.9")
        
        print("✅ AudioSegment creation test passed")
    }
}

// You can call this from your main app to run tests:
// SimpleModelTests.runAllTests()