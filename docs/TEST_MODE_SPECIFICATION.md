# Test Mode - 测试模式详细说明

> **版本**: 1.0
> **创建日期**: 2025-11-16
> **最后更新**: 2025-11-16

---

## 目录

1. [概述](#概述)
2. [功能特性](#功能特性)
3. [测试类型](#测试类型)
4. [评分系统](#评分系统)
5. [数据模型](#数据模型)
6. [用户界面](#用户界面)
7. [技术实现](#技术实现)
8. [星星奖励](#星星奖励)
9. [错题本系统](#错题本系统)
10. [集成点](#集成点)

---

## 概述

Test Mode（测试模式）是VocFr应用的综合能力测试功能，旨在全面评估学习者对法语词汇的掌握程度。

### 设计理念

```
方案一（综合能力测试）+ 方案四（错题本）
├── 多维度评估：听、说、读、写、词性判断
├── 标准化评分：20题混合测试
├── 错题追踪：智能记录薄弱环节
└── 进度反馈：集成Progress系统
```

### 核心价值

- **全面评估**: 4种题型覆盖多个维度
- **精准诊断**: 错题本帮助定位薄弱点
- **持续激励**: 星星奖励和成就系统
- **灵活选择**: 支持单元测试和综合测试

---

## 功能特性

### 1. 测试范围

#### 单元测试 (Unit Test)
- 选择特定Unite（1-8）进行测试
- 题目范围：该单元内所有学习过的词汇
- 适合：单元学习完成后的复习测试

#### 综合测试 (Comprehensive Test)
- 覆盖所有已学习的词汇
- 题目范围：全部解锁单元的词汇
- 适合：阶段性总复习

### 2. 测试配置

| 参数 | 配置 |
|------|------|
| 总题数 | 20题 |
| 题型分布 | 每种题型5题 |
| 时间限制 | 10分钟（600秒） |
| 通过标准 | 60分及格 |

### 3. 实时功能

- ⏱️ **倒计时显示**: 最后90秒变红色提醒
- 📊 **进度显示**: 当前题号/总题数（如"5 / 20"）
- ⬅️➡️ **题目导航**: 支持前后翻看，可修改答案
- 💾 **自动保存**: 答案实时保存

---

## 测试类型

### 1. 看图选词 (Image to Word)

#### 题型说明
显示单词图片，从4个选项中选择正确的法语单词。

#### 界面示例
```
┌─────────────────────────┐
│  选择正确的法语单词      │
│                         │
│  [图片: 橡皮]            │
│                         │
│  A. crayon              │
│  B. gomme          ✓    │
│  C. stylo               │
│  D. livre               │
└─────────────────────────┘
```

#### 实现逻辑
```swift
private func generateImageToWordQuestion(word: Word, allWords: [Word]) -> TestQuestion? {
    // 正确答案：当前单词
    var options: [String] = [word.canonical]

    // 3个干扰项：同词性的其他单词
    let wrongWords = allWords
        .filter { $0.id != word.id && $0.partOfSpeech == word.partOfSpeech }
        .shuffled()
        .prefix(3)

    options.append(contentsOf: wrongWords.map { $0.canonical })
    options.shuffle()

    return TestQuestion(
        type: .imageToWord,
        word: word,
        options: options,
        correctAnswer: word.canonical
    )
}
```

---

### 2. 听音辨词 (Audio to Word)

#### 题型说明
播放单词发音，从4个选项中选择正确的单词。

#### 界面示例
```
┌─────────────────────────┐
│  听音选择正确的单词      │
│                         │
│  [🔊 播放发音]           │
│  (可重复播放)            │
│                         │
│  A. pomme               │
│  B. porte               │
│  C. livre          ✓    │
│  D. table               │
└─────────────────────────┘
```

#### 音频播放
```swift
Button(action: {
    AudioPlayerManager.shared.playWordAudio(for: word) { _ in }
}) {
    HStack {
        Image(systemName: "play.circle.fill")
            .font(.system(size: 50))
            .foregroundColor(.blue)
        Text("test.button.listen".localized)
    }
}
```

#### 特性
- 🔊 无限次重复播放
- 📱 适配静音模式（振动提示）
- 🎯 干扰项同词性，增加难度

---

### 3. 拼写题 (Spelling)

#### 题型说明
看图或听音，键入正确的法语拼写。

#### 界面示例
```
┌─────────────────────────┐
│  输入正确的拼写          │
│                         │
│  [图片: 门]              │
│  [🔊 播放]               │
│                         │
│  ┌──────────────────┐   │
│  │ porte            │   │
│  └──────────────────┘   │
│                         │
│  提示：5个字母           │
└─────────────────────────┘
```

#### 拼写检查
```swift
private func checkSpelling(input: String, correct: String) -> Bool {
    // 不区分大小写
    return input.lowercased() == correct.lowercased()
}

// 在TestViewModel中
if question.type == .spelling {
    isCorrect = userAnswer.lowercased() == question.correctAnswer.lowercased()
}
```

#### 特性
- ⌨️ 支持法语特殊字符
- 📝 不区分大小写
- 💡 显示单词长度提示

---

### 4. 名词阴阳性 (Gender Guess)

#### 题型说明
判断法语名词的性别（阳性/阴性）。

#### 界面示例
```
┌─────────────────────────┐
│  选择这个名词的性别      │
│                         │
│  [图片: 橡皮]            │
│                         │
│  gomme                  │
│                         │
│  ┌──────────────────┐   │
│  │ 阳性 (Masculin)  │   │
│  └──────────────────┘   │
│  ┌──────────────────┐   │
│  │ 阴性 (Féminin)   │✓ │
│  └──────────────────┘   │
└─────────────────────────┘
```

#### 性别判断逻辑
```swift
private func generateGenderQuestion(word: Word) -> TestQuestion {
    // 从WordForm中读取gender字段
    let correctGender: String
    if let mainForm = word.forms.first(where: { $0.isMainForm }),
       let gender = mainForm.gender {
        correctGender = gender == .masculine ? "masculine" : "feminine"
    } else if let firstForm = word.forms.first,
              let gender = firstForm.gender {
        correctGender = gender == .masculine ? "masculine" : "feminine"
    } else {
        // Fallback: default to masculine
        correctGender = "masculine"
    }

    return TestQuestion(
        type: .genderGuess,
        word: word,
        options: ["masculine", "feminine"],
        correctAnswer: correctGender
    )
}
```

#### 特性
- 🎯 **仅针对名词**: 自动过滤非名词词性
- 📚 **数据来源**: 从JSON数据的`genderOrPos`字段读取
- ✅ **准确性保证**: 直接使用WordForm.gender，避免解析错误

---

## 评分系统

### 1. 分数计算

```swift
let score = Int(Double(correctAnswers) / Double(totalQuestions) * 100)
// 例如：20题答对18题 = (18/20) * 100 = 90分
```

### 2. 星级评定

| 分数范围 | 星级 | 评价 | 说明 |
|---------|------|------|------|
| 90-100 | ⭐⭐⭐ | Excellent! | 优秀 |
| 75-89 | ⭐⭐ | Good! | 良好 |
| 60-74 | ⭐ | Pass | 及格 |
| 0-59 | - | Needs Review | 需要复习 |

```swift
var starRating: Int {
    if score >= 90 { return 3 }
    if score >= 75 { return 2 }
    if score >= 60 { return 1 }
    return 0
}
```

### 3. 评价文本

```swift
var ratingText: String {
    switch starRating {
    case 3:
        return "test.rating.excellent".localized  // "优秀！"
    case 2:
        return "test.rating.good".localized       // "良好！"
    case 1:
        return "test.rating.pass".localized       // "及格"
    default:
        return "test.rating.review".localized     // "需要复习"
    }
}
```

---

## 数据模型

### 1. TestQuestion - 测试题目

```swift
struct TestQuestion: Identifiable {
    let id: String              // UUID
    let type: TestQuestionType  // 题型
    let word: Word              // 关联单词
    let options: [String]       // 选项（选择题）
    let correctAnswer: String   // 正确答案
}

enum TestQuestionType: String, Codable {
    case imageToWord      // 看图选词
    case audioToWord      // 听音辨词
    case spelling         // 拼写题
    case genderGuess      // 名词性别判断
}
```

### 2. TestResult - 测试结果

```swift
struct TestResult {
    let score: Int                          // 分数 (0-100)
    let totalQuestions: Int                 // 总题数 (20)
    let correctAnswers: Int                 // 正确题数
    let timeSpent: TimeInterval             // 用时（秒）
    let questionResults: [QuestionResult]   // 每题详情

    var starRating: Int {
        // 星级评定
    }

    var ratingText: String {
        // 评价文本
    }
}
```

### 3. QuestionResult - 单题结果

```swift
struct QuestionResult {
    let questionId: String
    let questionType: TestQuestionType
    let wordId: String
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
}
```

### 4. TestRecord - 测试记录（持久化）

```swift
@Model
final class TestRecord {
    var id: String
    var date: Date
    var uniteId: String?           // nil = 综合测试
    var uniteNumber: Int?
    var score: Int
    var totalQuestions: Int
    var correctAnswers: Int
    var timeSpent: TimeInterval
    var questionResults: [QuestionResult]

    init(uniteId: String?, uniteNumber: Int?, score: Int,
         totalQuestions: Int, correctAnswers: Int,
         timeSpent: TimeInterval, questionResults: [QuestionResult]) {
        self.id = UUID().uuidString
        self.date = Date()
        self.uniteId = uniteId
        self.uniteNumber = uniteNumber
        self.score = score
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.timeSpent = timeSpent
        self.questionResults = questionResults
    }
}
```

---

## 用户界面

### 1. 测试选择界面 (TestSelectionView)

```
┌─────────────────────────────┐
│  📝 Test Mode               │
│                             │
│  ┌─────────────────────┐   │
│  │ 综合测试             │   │
│  │ All Units           │   │
│  │ 218 words          │   │
│  │ Best: 85 ⭐⭐       │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ Unité 1 : A l'école │   │
│  │ 77 words           │   │
│  │ Best: 90 ⭐⭐⭐     │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ Unité 2 : Les sports│   │
│  │ 65 words           │   │
│  │ Best: -- (未测试)   │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

#### 特性
- 📊 显示最佳成绩
- 🔒 未解锁单元显示锁定状态
- 📈 显示单词数量

---

### 2. 测试进行界面 (TestSessionView)

#### 顶部进度栏
```
┌─────────────────────────────┐
│  5 / 20        ⏱️ 07:32     │
└─────────────────────────────┘
```

#### 题目区域
```
┌─────────────────────────────┐
│  选择正确的法语单词          │
│                             │
│  [图片显示区域]              │
│                             │
│  ○ A. option1               │
│  ○ B. option2               │
│  ○ C. option3               │
│  ○ D. option4               │
└─────────────────────────────┘
```

#### 底部导航
```
┌─────────────────────────────┐
│  [← 上一题]  [下一题 →]      │
│         [提交测试]           │
└─────────────────────────────┘
```

---

### 3. 结果展示界面 (TestResultView)

```
┌─────────────────────────────┐
│         🎉 测试完成          │
│                             │
│      ⭐ ⭐ ⭐               │
│                             │
│          90                 │
│       优秀！                │
│                             │
│  ┌─────────────────────┐   │
│  │ 正确: 18/20         │   │
│  │ 用时: 08:32         │   │
│  │                     │   │
│  │ 看图选词: 5/5  ✓    │   │
│  │ 听音辨词: 4/5       │   │
│  │ 拼写题:   5/5  ✓    │   │
│  │ 词性判断: 4/5       │   │
│  └─────────────────────┘   │
│                             │
│  [查看错题本]  [返回]        │
└─────────────────────────────┘
```

---

## 技术实现

### 1. TestViewModel - 核心逻辑

```swift
@Observable
class TestViewModel {
    // MARK: - Properties
    let unite: Unite?                       // nil = 综合测试
    private let modelContext: ModelContext?

    var questions: [TestQuestion] = []      // 所有题目
    var currentIndex: Int = 0               // 当前题号
    var answers: [String: String] = [:]     // 答案记录
    var startTime: Date = Date()            // 开始时间
    var timeLimit: TimeInterval = 600       // 10分钟
    var elapsedTime: TimeInterval = 0       // 已用时间

    // MARK: - Setup
    private func setupQuestions() {
        // 1. 收集单词
        var words: [Word] = []
        // ... 从unite或所有unites收集

        // 2. 生成题目（每种5题）
        var generatedQuestions: [TestQuestion] = []

        // 看图选词 x5
        let imageWords = words.shuffled().prefix(5)
        for word in imageWords {
            if let q = generateImageToWordQuestion(word: word, allWords: words) {
                generatedQuestions.append(q)
            }
        }

        // 听音辨词 x5
        // 拼写题 x5
        // 词性判断 x5 (仅名词)

        // 3. 打乱顺序
        questions = generatedQuestions.shuffled()
    }

    // MARK: - Actions
    func submitAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }
        answers[question.id] = answer
    }

    func finishTest() -> TestResult {
        // 1. 计算成绩
        var correctCount = 0
        var questionResults: [QuestionResult] = []

        for question in questions {
            let userAnswer = answers[question.id] ?? ""
            let isCorrect = checkAnswer(userAnswer, for: question)

            if isCorrect { correctCount += 1 }

            questionResults.append(QuestionResult(
                questionId: question.id,
                questionType: question.type,
                wordId: question.word.id,
                userAnswer: userAnswer,
                correctAnswer: question.correctAnswer,
                isCorrect: isCorrect,
                timeSpent: 0
            ))

            // 2. 保存错题
            if !isCorrect {
                saveWrongAnswer(question: question, userAnswer: userAnswer)
            }
        }

        // 3. 生成结果
        let score = Int(Double(correctCount) / Double(questions.count) * 100)
        let result = TestResult(
            score: score,
            totalQuestions: questions.count,
            correctAnswers: correctCount,
            timeSpent: elapsedTime,
            questionResults: questionResults
        )

        // 4. 保存记录
        saveTestRecord(result: result)

        return result
    }
}
```

---

### 2. 性别判断修复

**问题**: 之前从`word.canonical`解析冠词来判断性别，但canonical不包含冠词。

**解决方案**: 从`WordForm.gender`字段直接读取

```swift
// ❌ 错误方法（已废弃）
if word.canonical.hasPrefix("le ") {
    correctGender = "masculine"
}

// ✅ 正确方法（当前实现）
if let mainForm = word.forms.first(where: { $0.isMainForm }),
   let gender = mainForm.gender {
    correctGender = gender == .masculine ? "masculine" : "feminine"
}
```

---

### 3. 数据来源

```json
// vocabulary.json
{
  "canonical": "gomme",
  "chinese": "橡皮",
  "partOfSpeech": "noun",
  "genderOrPos": "feminine",  // ← 性别数据源
  "category": "school_objects",
  "elision": false
}
```

加载时转换为：
```swift
WordForm(
    formType: .singular,
    french: "la gomme",
    articleOnly: "la",
    gender: .feminine,    // ← 存储在这里
    number: .singular,
    isMainForm: true
)
```

---

## 星星奖励

### 奖励规则

```swift
// 星星 = 分数 ÷ 10
let stars = result.score / 10

// 示例：
// 100分 → 10星
//  90分 → 9星
//  85分 → 8星
//  75分 → 7星
//  60分 → 6星
```

### 实现代码

```swift
private func saveTestRecord(result: TestResult) {
    // ... 保存TestRecord

    // Award stars based on performance
    let stars = result.score / 10
    if stars > 0 {
        PointsManager.shared.awardStars(
            points: stars,
            modelContext: modelContext,
            reason: "Test completed with score \(result.score)"
        )
    }
}
```

---

## 错题本系统

### 1. WrongAnswerRecord - 错题记录

```swift
@Model
final class WrongAnswerRecord {
    var id: String
    var wordId: String              // 单词ID
    var questionType: String        // 题型
    var userAnswer: String          // 错误答案
    var correctAnswer: String       // 正确答案
    var wrongCount: Int             // 错误次数
    var lastWrongDate: Date         // 最近错误日期
    var isMastered: Bool            // 是否已掌握

    init(wordId: String, questionType: TestQuestionType,
         userAnswer: String, correctAnswer: String) {
        self.id = UUID().uuidString
        self.wordId = wordId
        self.questionType = questionType.rawValue
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.wrongCount = 1
        self.lastWrongDate = Date()
        self.isMastered = false
    }
}
```

### 2. 错题保存逻辑

```swift
private func saveWrongAnswer(question: TestQuestion, userAnswer: String) {
    guard let modelContext = modelContext else { return }

    let wordId = question.word.id
    let questionTypeValue = question.type.rawValue

    // 查询是否已有记录
    let descriptor = FetchDescriptor<WrongAnswerRecord>(
        predicate: #Predicate { record in
            record.wordId == wordId &&
            record.questionType == questionTypeValue
        }
    )

    if let existing = try? modelContext.fetch(descriptor).first {
        // 更新已有记录
        existing.lastWrongDate = Date()
        existing.wrongCount += 1
        existing.userAnswer = userAnswer
    } else {
        // 创建新记录
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
```

### 3. 错题本界面 (WrongAnswerBookView)

```
┌─────────────────────────────┐
│  📕 错题本                   │
│                             │
│  共 5 道错题                │
│                             │
│  ┌─────────────────────┐   │
│  │ gomme              │   │
│  │ 听音辨词            │   │
│  │ 你的答案: gommes    │   │
│  │ 正确答案: gomme     │   │
│  │ 错误次数: 2次       │   │
│  │ [标记为已掌握]      │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ porte              │   │
│  │ 词性判断            │   │
│  │ 你的答案: masculine │   │
│  │ 正确答案: feminine  │   │
│  │ 错误次数: 1次       │   │
│  │ [标记为已掌握]      │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

---

## 集成点

### 1. Progress页面集成

```swift
// TestViewModel.swift
private func saveTestRecord(result: TestResult) {
    // ... 保存TestRecord

    // 创建PracticeRecord用于Progress页面
    let sessionTypeName: String
    if let unite = unite {
        sessionTypeName = "Test - Unité \(unite.number)"
    } else {
        sessionTypeName = "Test - Comprehensive"
    }

    let practiceRecord = PracticeRecord(
        sessionDate: Date(),
        sessionType: sessionTypeName,
        wordsStudied: result.totalQuestions,
        accuracy: Double(result.correctAnswers) / Double(result.totalQuestions),
        timeSpent: result.timeSpent
    )

    modelContext.insert(practiceRecord)
}
```

### 2. Recent Activity显示

```
Progress页面 → Recent Activity:
┌─────────────────────────────┐
│  Test - Unité 1             │
│  2025-11-16  20 words       │
│  正确率: 90%  用时: 8:32     │
└─────────────────────────────┘
```

---

## 本地化

### 关键字符串

```swift
// 测试类型
"test.question.imageToWord" = "选择正确的法语单词"
"test.question.audioToWord" = "听音选择正确的单词"
"test.question.spelling" = "输入正确的拼写"
"test.question.genderGuess" = "选择这个名词的性别"

// 性别
"test.gender.masculine" = "阳性 (Masculin)"
"test.gender.feminine" = "阴性 (Féminin)"

// 按钮
"test.button.listen" = "播放发音"
"test.button.submit" = "提交测试"
"test.button.next" = "下一题"
"test.button.previous" = "上一题"
"test.button.viewWrong" = "查看错题本"

// 评价
"test.rating.excellent" = "优秀！"
"test.rating.good" = "良好！"
"test.rating.pass" = "及格"
"test.rating.review" = "需要复习"

// 综合测试
"test.comprehensive" = "综合测试"
"test.all.units" = "全部单元"
```

---

## 文件结构

```
VocFr/
├── Models/
│   └── TestModels.swift           // 数据模型
├── ViewModels/
│   └── TestViewModel.swift        // 测试逻辑
├── Views/
│   └── Practice/
│       ├── TestModeView.swift     // 入口
│       ├── TestSelectionView.swift    // 选择界面
│       ├── TestSessionView.swift      // 测试界面
│       ├── TestResultView.swift       // 结果界面
│       └── WrongAnswerBookView.swift  // 错题本
└── {language}.lproj/
    └── Localizable.strings        // 本地化字符串
```

---

## 总结

### 已实现功能 ✅

- [x] 4种测试题型（看图选词、听音辨词、拼写题、词性判断）
- [x] 单元测试和综合测试
- [x] 20题混合测试，10分钟时限
- [x] 星级评分系统（⭐⭐⭐）
- [x] 星星奖励（分数÷10）
- [x] 错题本系统
- [x] Progress页面集成
- [x] 7种语言本地化支持
- [x] 性别判断准确性修复

### 未来优化方向 🚀

- [ ] 题目难度自适应
- [ ] 错题重点复习模式
- [ ] 测试历史详细分析
- [ ] 单词掌握度可视化
- [ ] 测试排行榜
- [ ] 自定义测试配置（题数、时限、题型）

---

**文档维护者**: Claude
**技术栈**: SwiftUI, SwiftData, AVFoundation
**最后测试**: 2025-11-16
