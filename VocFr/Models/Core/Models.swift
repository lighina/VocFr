import Foundation
import SwiftData

// MARK: - Enums

enum PartOfSpeech: String, CaseIterable, Codable {
    case noun = "名词"
    case verb = "动词"
    case adjective = "形容词"
    case number = "数词"
    case pronoun = "代词"
    case preposition = "介词"
    case other = "其他"
}

enum WordFormType: String, CaseIterable, Codable {
    case indefiniteArticle = "不定冠词"
    case definiteArticle = "定冠词"
    case withElision = "省音形式"
    case baseForm = "基本形式"
}

enum Gender: String, CaseIterable, Codable {
    case masculine = "阳性"
    case feminine = "阴性"
}

enum Number: String, CaseIterable, Codable {
    case singular = "单数"
    case plural = "复数"
}

enum AudioQuality: String, CaseIterable, Codable {
    case high = "高质量"
    case normal = "普通"
    case low = "低质量"
}

// MARK: - Main Models

@Model
class Unite {
    var id: String
    var number: Int
    var title: String
    var isUnlocked: Bool
    var requiredStars: Int
    
    @Relationship(deleteRule: .cascade, inverse: \Section.unite)
    var sections: [Section] = []
    
    init(id: String, number: Int, title: String, isUnlocked: Bool, requiredStars: Int) {
        self.id = id
        self.number = number
        self.title = title
        self.isUnlocked = isUnlocked
        self.requiredStars = requiredStars
    }
}

@Model
class Section {
    var id: String
    var name: String
    var orderIndex: Int
    
    var unite: Unite?
    
    @Relationship(deleteRule: .cascade, inverse: \SectionWord.section)
    var sectionWords: [SectionWord] = []
    
    init(id: String, name: String, orderIndex: Int) {
        self.id = id
        self.name = name
        self.orderIndex = orderIndex
    }
}

@Model
class Word {
    var id: String
    var canonical: String
    var chinese: String
    var imageName: String
    var partOfSpeech: PartOfSpeech
    var category: String
    
    @Relationship(deleteRule: .cascade, inverse: \WordForm.word)
    var forms: [WordForm] = []
    
    @Relationship(deleteRule: .cascade, inverse: \SectionWord.word)
    var sectionWords: [SectionWord] = []
    
    @Relationship(deleteRule: .cascade, inverse: \AudioSegment.word)
    var audioSegments: [AudioSegment] = []
    
    @Relationship(deleteRule: .cascade, inverse: \WordProgress.word)
    var wordProgresses: [WordProgress] = []
    
    init(id: String, canonical: String, chinese: String, imageName: String, partOfSpeech: PartOfSpeech, category: String) {
        self.id = id
        self.canonical = canonical
        self.chinese = chinese
        self.imageName = imageName
        self.partOfSpeech = partOfSpeech
        self.category = category
    }
}

@Model
class WordForm {
    var formType: WordFormType
    var french: String
    var articleOnly: String?
    var gender: Gender?
    var number: Number?
    var isMainForm: Bool
    
    var word: Word?
    
    init(formType: WordFormType, french: String, articleOnly: String? = nil, gender: Gender? = nil, number: Number? = nil, isMainForm: Bool = false) {
        self.formType = formType
        self.french = french
        self.articleOnly = articleOnly
        self.gender = gender
        self.number = number
        self.isMainForm = isMainForm
    }
}

@Model
class SectionWord {
    var orderIndex: Int
    
    var section: Section?
    var word: Word?
    
    init(orderIndex: Int) {
        self.orderIndex = orderIndex
    }
}

@Model
class AudioFile {
    var fileName: String
    var filePath: String
    var duration: Double
    
    @Relationship(deleteRule: .cascade, inverse: \AudioSegment.audioFile)
    var audioSegments: [AudioSegment] = []
    
    init(fileName: String, filePath: String, duration: Double) {
        self.fileName = fileName
        self.filePath = filePath
        self.duration = duration
    }
}

@Model
class AudioSegment {
    var startTime: Double
    var endTime: Double
    var formType: WordFormType
    var quality: AudioQuality
    var confidence: Double
    
    var word: Word?
    var audioFile: AudioFile?
    
    init(startTime: Double, endTime: Double, formType: WordFormType, quality: AudioQuality, confidence: Double) {
        self.startTime = startTime
        self.endTime = endTime
        self.formType = formType
        self.quality = quality
        self.confidence = confidence
    }
}

// MARK: - Progress Tracking Models

@Model
class UserProgress {
    var totalStars: Int
    var currentStreak: Int
    var lastStudyDate: Date?
    
    @Relationship(deleteRule: .cascade, inverse: \WordProgress.userProgress)
    var wordProgresses: [WordProgress] = []
    
    @Relationship(deleteRule: .cascade, inverse: \PracticeRecord.userProgress)
    var practiceRecords: [PracticeRecord] = []
    
    init() {
        self.totalStars = 0
        self.currentStreak = 0
        self.lastStudyDate = nil
    }
}

@Model
class WordProgress {
    var masteryLevel: Int
    var correctCount: Int
    var incorrectCount: Int
    var lastReviewed: Date?
    var nextReviewDate: Date?
    
    var word: Word?
    var userProgress: UserProgress?
    
    init() {
        self.masteryLevel = 0
        self.correctCount = 0
        self.incorrectCount = 0
        self.lastReviewed = nil
        self.nextReviewDate = nil
    }
}

@Model
class PracticeRecord {
    var sessionDate: Date
    var sessionType: String
    var wordsStudied: Int
    var accuracy: Double
    var timeSpent: TimeInterval
    
    var userProgress: UserProgress?
    
    init(sessionDate: Date, sessionType: String, wordsStudied: Int, accuracy: Double, timeSpent: TimeInterval) {
        self.sessionDate = sessionDate
        self.sessionType = sessionType
        self.wordsStudied = wordsStudied
        self.accuracy = accuracy
        self.timeSpent = timeSpent
    }
}

// MARK: - Legacy Item Model (for compatibility)

@Model
class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}