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
    var requiredGems: Int  // Alternative unlock cost: 100💎 for Unite 2, 200💎 for Unite 3, etc.

    @Relationship(deleteRule: .cascade, inverse: \Section.unite)
    var sections: [Section] = []

    init(id: String, number: Int, title: String, isUnlocked: Bool, requiredStars: Int, requiredGems: Int = 0) {
        self.id = id
        self.number = number
        self.title = title
        self.isUnlocked = isUnlocked
        self.requiredStars = requiredStars
        self.requiredGems = requiredGems
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
    var totalGems: Int
    var currentStreak: Int
    var lastStudyDate: Date?
    var lastMasteredMilestone: Int  // Track mastered milestone for gems reward (0, 10, 20, 30...)

    @Relationship(deleteRule: .cascade, inverse: \WordProgress.userProgress)
    var wordProgresses: [WordProgress] = []

    @Relationship(deleteRule: .cascade, inverse: \PracticeRecord.userProgress)
    var practiceRecords: [PracticeRecord] = []

    init() {
        self.totalStars = 0
        self.totalGems = 5  // Initial gems: 5💎
        self.currentStreak = 0
        self.lastStudyDate = nil
        self.lastMasteredMilestone = 0
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

// MARK: - Game Mode Models

@Model
class GameMode {
    @Attribute(.unique) var id: String
    var name: String
    var nameInChinese: String
    var descriptionText: String
    var isUnlocked: Bool
    var requiredGems: Int
    var orderIndex: Int
    var iconName: String  // SF Symbol name

    init(id: String, name: String, nameInChinese: String, descriptionText: String, isUnlocked: Bool, requiredGems: Int, orderIndex: Int, iconName: String) {
        self.id = id
        self.name = name
        self.nameInChinese = nameInChinese
        self.descriptionText = descriptionText
        self.isUnlocked = isUnlocked
        self.requiredGems = requiredGems
        self.orderIndex = orderIndex
        self.iconName = iconName
    }
}

// MARK: - Storybook Models

@Model
class Storybook {
    @Attribute(.unique) var id: String
    var title: String
    var titleInChinese: String
    var uniteId: String  // Which Unite this storybook belongs to
    var isUnlocked: Bool
    var requiredGems: Int  // Cost to unlock (0 if unlocked by completing Unite test)
    var orderIndex: Int
    var coverImageName: String?

    @Relationship(deleteRule: .cascade, inverse: \StoryPage.storybook)
    var pages: [StoryPage] = []

    init(id: String, title: String, titleInChinese: String, uniteId: String, isUnlocked: Bool, requiredGems: Int, orderIndex: Int, coverImageName: String? = nil) {
        self.id = id
        self.title = title
        self.titleInChinese = titleInChinese
        self.uniteId = uniteId
        self.isUnlocked = isUnlocked
        self.requiredGems = requiredGems
        self.orderIndex = orderIndex
        self.coverImageName = coverImageName
    }
}

@Model
class StoryPage {
    var pageNumber: Int
    var contentFrench: String
    var contentChinese: String
    var imageName: String?
    var audioFileName: String?

    var storybook: Storybook?

    init(pageNumber: Int, contentFrench: String, contentChinese: String, imageName: String? = nil, audioFileName: String? = nil) {
        self.pageNumber = pageNumber
        self.contentFrench = contentFrench
        self.contentChinese = contentChinese
        self.imageName = imageName
        self.audioFileName = audioFileName
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