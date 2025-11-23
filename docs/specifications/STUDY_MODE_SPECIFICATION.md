# Study Mode - 学习模式详细说明

> **版本**: 1.0
> **创建日期**: 2025-11-16
> **最后更新**: 2025-11-16

---

## 目录

1. [概述](#概述)
2. [学习层级结构](#学习层级结构)
3. [界面详解](#界面详解)
4. [功能特性](#功能特性)
5. [导航系统](#导航系统)
6. [星星奖励](#星星奖励)
7. [数据模型](#数据模型)
8. [技术实现](#技术实现)
9. [用户体验](#用户体验)

---

## 概述

Study Mode（学习模式）是VocFr应用的核心学习功能，提供结构化的词汇学习路径。用户通过层级式导航系统，从Unite到Section再到单词详情，系统地学习法语词汇。

### 设计理念

```
学习模式 = 浏览 + 记忆 + 复习
├── 结构化学习路径 (Unite → Section → Word)
├── 即时音频反馈 (真人发音)
├── 多感官学习 (视觉 + 听觉)
└── 灵活导航 (手势 + 菜单)
```

### 核心价值

- **系统化学习**: 按单元和章节组织，循序渐进
- **沉浸式体验**: 图片+音频的多感官学习
- **自主探索**: 用户可自由浏览和复习
- **无压力环境**: 纯浏览模式，无测试压力

---

## 学习层级结构

### 四级导航体系

```
Level 1: UnitsView (单元列表)
    ├── Unite 1: À l'école ✓
    ├── Unite 2: Les sports ✓
    ├── Unite 3: La nourriture 🔒 (需要120星)
    └── ...
         ↓
Level 2: UniteDetailView (章节列表)
    ├── Section 1: Les fournitures scolaires
    ├── Section 2: Les matières
    └── Section 3: À la récréation
         ↓
Level 3: SectionDetailView (单词列表)
    ├── le crayon (铅笔)
    ├── la gomme (橡皮)
    ├── le stylo (钢笔)
    └── ...
         ↓
Level 4: WordDetailView (单词详情)
    ├── 图片: 橡皮图像
    ├── 法语: la gomme (f.)
    ├── 中文: 橡皮
    └── 音频: 🔊 [播放]
```

---

## 界面详解

### 1. UnitsView - 单元列表界面

```
┌─────────────────────────────────┐
│  📚 Units                    ⬇️ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ ⭐ 218 / 420              │ │
│  │ ████████░░░░░░░           │ │
│  │ Unite 6 unlocks at 420 ⭐ │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Unité 1 : À l'école   ✓   │ │
│  │ 3 sections                │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Unité 2 : Les sports  ✓   │ │
│  │ 3 sections                │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Unité 3 : ...         🔒  │ │
│  │ 3 sections   Needs 120 ⭐ │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

#### 特性
- **星星进度条** (StarsProgressView)
  - 当前星星数 / 下一解锁所需星星数
  - 进度条可视化
  - 显示下一个解锁单元信息

- **单元状态**
  - ✓ 已解锁：可以点击进入
  - 🔒 未解锁：显示所需星星数，置灰不可点

- **每日登录奖励**
  - 页面加载时自动触发
  - 每天首次打开获得2⭐
  - 连续7天额外50⭐

---

### 2. UniteDetailView - 单元详情界面

```
┌─────────────────────────────────┐
│  ← Unité 1 : À l'école          │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Les fournitures scolaires │ │
│  │ 15 words                  │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ Les matières              │ │
│  │ 12 words                  │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ À la récréation           │ │
│  │ 18 words                  │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

#### 特性
- **章节列表**: 显示Unite内所有Section
- **单词计数**: 每个Section的单词数量
- **右滑返回**: 从左边缘右滑返回上级

---

### 3. SectionDetailView - 章节详情界面

```
┌─────────────────────────────────┐
│  ← Unité 1  ⋯  [练习 ▼]         │
│  Les fournitures scolaires      │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🖼️ le crayon             │ │
│  │    铅笔                   │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🖼️ la gomme              │ │
│  │    橡皮                   │ │
│  └───────────────────────────┘ │
│                                 │
│  ┌───────────────────────────┐ │
│  │ 🖼️ le stylo              │ │
│  │    钢笔                   │ │
│  └───────────────────────────┘ │
└─────────────────────────────────┘

练习菜单:
├── 📷 看图选词
├── 🎧 听力练习
├── 📇 闪卡模式
├── ⌨️ 拼写练习
└── 🎮 配对游戏
```

#### 特性
- **单词列表**: 显示Section内所有单词
- **缩略信息**: 图片缩略图 + 法语单词 + 中文释义
- **练习入口**: 右上角练习菜单，5种练习模式
- **导航菜单**: 可直接跳转到Home或Unite
- **右滑返回**: 手势导航

---

### 4. WordDetailView - 单词详情界面

```
┌─────────────────────────────────┐
│ ← Les fournitures  ⋯  👁️  🔀   │
│                                 │
│         [轻触查看单词]           │
│                                 │
│         ┌─────────┐             │
│         │         │             │
│         │  🖼️    │             │
│         │  橡皮   │             │
│         │         │             │
│         └─────────┘             │
│                                 │
│                                 │
│                                 │
└─────────────────────────────────┘

[点击图片后]
┌─────────────────────────────────┐
│ ← Les fournitures  ⋯  👁️  🔀   │
│                                 │
│         ┌─────────┐             │
│         │  🖼️    │             │
│         │  橡皮   │             │
│         └─────────┘             │
│                                 │
│      ┌───────────────┐          │
│      │  la gomme     │          │
│      │  (f.)         │          │
│      │               │          │
│      │  [🔊 播放]    │          │
│      └───────────────┘          │
│                                 │
└─────────────────────────────────┘
```

#### 界面元素详解

##### 顶部工具栏
- **← Les fournitures**: 返回按钮（显示Section名称）
- **⋯**: 导航菜单（Home / Unité / Section）
- **👁️**: 显示/隐藏单词卡片
- **🔀**: 洗牌模式开关

##### 主内容区
1. **单词图片**
   - 大尺寸居中显示（250x250）
   - 点击图片显示单词卡片
   - 如无图片显示占位符

2. **单词卡片**（点击后显示）
   - 法语单词：如 "la gomme"
   - 词性标注：(f.) = 阴性名词
   - 播放按钮：真人发音

##### 词性显示规则

```swift
// 名词
"la gomme" → "la gomme (f.)"       // 阴性名词
"le stylo" → "le stylo (m.)"       // 阳性名词

// 动词
"manger" → "manger (v.)"           // 动词

// 形容词
"rouge" → "rouge (adj.)"           // 形容词

// 副词
"très" → "très (adv.)"             // 副词
```

---

## 功能特性

### 1. 图片展示

#### 实现逻辑
```swift
if word.hasImage && imageExists(named: word.imageName) {
    Image(word.imageName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: 250, maxHeight: 250)
} else {
    // 占位符
    RoundedRectangle(cornerRadius: 20)
        .fill(Color.gray.opacity(0.2))
        .frame(width: 250, height: 200)
        .overlay(
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.6))
        )
}
```

#### 特性
- 自适应大小（最大250x250）
- 保持纵横比
- 无图片时显示灰色占位符
- 点击图片触发单词卡片显示

#### 图片命名规则（v1.1+）

**1. 默认命名**：
```swift
// 自动规范化并添加 _image 后缀
"école" → "ecole_image.png"
"chat" → "chat_image.png"
```

**2. 自定义命名（同形异义词）**：
```json
// Unite JSON中指定 nameOfImage
{
  "canonical": "orange",
  "partOfSpeech": "adjective",
  "nameOfImage": "orange_color_image"  // 橙色
}
{
  "canonical": "orange",
  "partOfSpeech": "noun",
  "nameOfImage": "orange_fruit_image"  // 橙子
}
```

**3. 无图片单词（表达式/句子）**：
```json
{
  "canonical": "Bon appétit",
  "type": "expression",
  "nameOfImage": "none"  // 或 "null" 或留空
}
```

#### 单词过滤

**hasImage 属性**：
```swift
// Word.swift
var hasImage: Bool {
    return !imageName.isEmpty && imageName.lowercased() != "none"
}

// 使用示例：筛选有图片的单词用于视觉练习模式
let visualWords = allWords.filter { $0.hasImage }
```

**用途**：
- 视觉练习模式（看图选词）：只使用 `hasImage == true` 的单词
- 表达式和句子自动从图片练习中排除
- 确保练习模式的有效性和质量

---

### 2. 音频播放

#### 播放机制
```swift
// 使用AudioPlayerManager统一管理音频
Button(action: { playAudio(for: word) }) {
    Image(systemName: audioManager.isPlaying ? "stop.fill" : "play.fill")
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.white)
        .frame(width: 44, height: 44)
        .background(Color.blue)
        .clipShape(Circle())
}

private func playAudio(for word: Word) {
    AudioPlayerManager.shared.playWordAudio(for: word) { success in
        if !success {
            print("⚠️ Failed to play audio for word: \(word.canonical)")
        }
    }
}
```

#### 音频来源
```
Word → AudioSegment → AudioFile
├── word.audioSegments[0].startTime
├── word.audioSegments[0].endTime
└── word.audioSegments[0].audioFile.fileName
```

#### 特性
- 真人发音（从音频文件截取）
- 播放状态动画（播放/停止图标切换）
- 错误处理（无音频时静默失败）

---

### 3. 单词卡片显示/隐藏

#### 状态控制
```swift
@State private var viewModel: WordDetailViewModel

// 显示/隐藏逻辑
func toggleWordCard() {
    withAnimation(.easeInOut) {
        showWordCard.toggle()
    }
}

// 界面渲染
if viewModel.showWordCard {
    // 显示单词卡片
    VStack {
        Text(getWordTitle(for: word))
        Text(getGrammaticalIndicator(for: word))
        Button { playAudio(for: word) } { ... }
    }
} else {
    // 显示提示
    Text("word.detail.tap.hint".localized)  // "轻触查看单词"
}
```

#### 用途
- 自测模式：先看图片猜单词，再显示答案
- 记忆巩固：通过隐藏增加回忆难度
- 专注学习：减少视觉干扰

---

### 4. 单词洗牌模式

#### 功能说明
```swift
ToolbarIconButton(
    icon: "shuffle",
    isActive: viewModel.isShuffled,
    activeColor: .green
) {
    toggleShuffle()
}

private func toggleShuffle() {
    withAnimation(.easeInOut(duration: 0.3)) {
        viewModel.toggleShuffle()

        // 洗牌后跳到第一个单词
        if viewModel.isShuffled {
            viewModel.currentWordIndex = 0
        }
    }
}
```

#### 特性
- 随机顺序学习单词
- 避免顺序记忆
- 可随时开关
- 状态持久化（在当前Section内）

---

### 5. 左右滑动切换单词

#### 手势识别
```swift
.gesture(
    DragGesture()
        .onChanged { value in
            dragOffset = value.translation.width
        }
        .onEnded { value in
            let threshold: CGFloat = 50

            if value.translation.width > threshold {
                // 向右滑：上一个单词
                previousWord()
            } else if value.translation.width < -threshold {
                // 向左滑：下一个单词
                nextWord()
            }

            dragOffset = 0
        }
)
```

#### 导航逻辑
```swift
private func previousWord() {
    guard viewModel.canGoToPrevious else { return }

    withAnimation(.easeInOut(duration: 0.3)) {
        viewModel.goToPreviousWord()
    }
}

private func nextWord() {
    guard viewModel.canGoToNext else { return }

    withAnimation(.easeInOut(duration: 0.3)) {
        viewModel.goToNextWord()
    }
}
```

#### 边界处理
- 第一个单词：无法向左滑（canGoToPrevious = false）
- 最后一个单词：无法向右滑（canGoToNext = false）
- 循环模式：可选（当前未实现）

---

### 6. 右滑返回手势

#### 系统级导航
```swift
.gesture(
    DragGesture()
        .onChanged { value in
            // 只从左边缘开始的右滑
            if value.startLocation.x < 50 && value.translation.width > 0 {
                dragOffset = value.translation.width
            }
        }
        .onEnded { value in
            // 滑动超过100点返回
            if value.startLocation.x < 50 && value.translation.width > 100 {
                dismiss()
            }
            dragOffset = 0
        }
)
```

#### 应用范围
- UniteDetailView → UnitsView
- SectionDetailView → UniteDetailView
- WordDetailView → SectionDetailView

---

## 导航系统

### 1. NavigationCoordinator

```swift
@Observable
class NavigationCoordinator {
    var popToRootTrigger: Bool = false
    var popToUniteDetailTrigger: Bool = false
    var popToSectionDetailTrigger: Bool = false

    func popToRoot() {
        popToRootTrigger.toggle()
    }

    func popToUniteDetail() {
        popToUniteDetailTrigger.toggle()
    }

    func popToSectionDetail() {
        popToSectionDetailTrigger.toggle()
    }
}
```

### 2. 导航菜单

#### WordDetailView导航菜单
```swift
Menu {
    Button(action: {
        navigationCoordinator.popToRoot()
    }) {
        Label("Home", systemImage: "house")
    }
    Button(action: {
        navigationCoordinator.popToUniteDetail()
    }) {
        Label(getUniteName(), systemImage: "book.closed")
    }
    Button(action: {
        navigationCoordinator.popToSectionDetail()
    }) {
        Label(section.name, systemImage: "list.dash")
    }
} label: {
    Image(systemName: "ellipsis.circle")
}
```

---

## 星星奖励

### 浏览奖励机制

#### 触发时机
```swift
// UniteDetailView.swift
// 每次进入Unite时触发（但只奖励一次）
.onAppear {
    // 奖励5星（每个Section浏览一次）
    PointsManager.shared.awardSectionBrowsePoints(modelContext: modelContext)
}
```

#### 奖励规则

| 活动 | 星星数 | 频率 | 说明 |
|------|--------|------|------|
| 浏览Section | 5⭐ | 每个Section一次 | 鼓励系统学习 |

#### 实现代码
```swift
// PointsManager.swift
func awardSectionBrowsePoints(modelContext: ModelContext) {
    addPoints(RewardPoints.sectionBrowse, to: modelContext, reason: "Section browsed")
}

struct RewardPoints {
    static let sectionBrowse = 5
}
```

---

## 数据模型

### 1. Unite - 单元

```swift
@Model
class Unite {
    var id: String
    var number: Int
    var title: String
    var requiredStars: Int
    var isUnlocked: Bool

    @Relationship(deleteRule: .cascade, inverse: \Section.unite)
    var sections: [Section] = []

    init(id: String, number: Int, title: String, requiredStars: Int) {
        self.id = id
        self.number = number
        self.title = title
        self.requiredStars = requiredStars
        self.isUnlocked = (number == 1) // Unite 1默认解锁
    }
}
```

---

### 2. Section - 章节

```swift
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
```

---

### 3. Word - 单词

```swift
@Model
class Word {
    var id: String
    var canonical: String       // 规范形式（如 "gomme", "stylo"）
    var chinese: String          // 中文释义
    var imageName: String        // 图片文件名
    var partOfSpeech: PartOfSpeech
    var category: String

    @Relationship(deleteRule: .cascade, inverse: \WordForm.word)
    var forms: [WordForm] = []   // 词形变化

    @Relationship(deleteRule: .cascade, inverse: \AudioSegment.word)
    var audioSegments: [AudioSegment] = []  // 音频片段

    init(id: String, canonical: String, chinese: String,
         imageName: String, partOfSpeech: PartOfSpeech, category: String) {
        self.id = id
        self.canonical = canonical
        self.chinese = chinese
        self.imageName = imageName
        self.partOfSpeech = partOfSpeech
        self.category = category
    }
}
```

---

### 4. WordForm - 词形

```swift
@Model
class WordForm {
    var formType: WordFormType      // singular, plural, etc.
    var french: String              // 完整形式（如 "la gomme"）
    var articleOnly: String?        // 冠词（如 "la"）
    var gender: Gender?             // 性别（masculine/feminine）
    var number: Number?             // 单复数
    var isMainForm: Bool            // 是否为主要形式

    var word: Word?

    init(formType: WordFormType, french: String,
         articleOnly: String? = nil, gender: Gender? = nil,
         number: Number? = nil, isMainForm: Bool = false) {
        self.formType = formType
        self.french = french
        self.articleOnly = articleOnly
        self.gender = gender
        self.number = number
        self.isMainForm = isMainForm
    }
}
```

---

### 5. PartOfSpeech - 词性

```swift
enum PartOfSpeech: String, CaseIterable, Codable {
    case noun = "名词"
    case verb = "动词"
    case adjective = "形容词"
    case adverb = "副词"
    case pronoun = "代词"
    case preposition = "介词"
    case conjunction = "连词"
    case interjection = "感叹词"
    case other = "其他"

    var abbreviation: String {
        switch self {
        case .noun: return "n."
        case .verb: return "v."
        case .adjective: return "adj."
        case .adverb: return "adv."
        case .pronoun: return "pron."
        case .preposition: return "prep."
        case .conjunction: return "conj."
        case .interjection: return "interj."
        case .other: return ""
        }
    }
}
```

---

## 技术实现

### 1. WordDetailViewModel

```swift
@Observable
class WordDetailViewModel {
    let section: Section
    var currentWordIndex: Int
    var showWordCard: Bool = false
    var isShuffled: Bool = false

    private var shuffledIndices: [Int] = []

    var currentWord: Word? {
        let words = section.sectionWords
            .sorted(by: { $0.orderIndex < $1.orderIndex })
            .compactMap { $0.word }

        guard !words.isEmpty else { return nil }

        let index = isShuffled ? shuffledIndices[currentWordIndex] : currentWordIndex
        guard index < words.count else { return nil }

        return words[index]
    }

    var canGoToPrevious: Bool {
        currentWordIndex > 0
    }

    var canGoToNext: Bool {
        let count = section.sectionWords.count
        return currentWordIndex < count - 1
    }

    func goToPreviousWord() {
        guard canGoToPrevious else { return }
        currentWordIndex -= 1
        showWordCard = false
    }

    func goToNextWord() {
        guard canGoToNext else { return }
        currentWordIndex += 1
        showWordCard = false
    }

    func toggleShuffle() {
        isShuffled.toggle()

        if isShuffled {
            // 生成随机索引
            let count = section.sectionWords.count
            shuffledIndices = Array(0..<count).shuffled()
        }
    }

    func showCard() {
        showWordCard = true
    }

    func toggleWordCard() {
        showWordCard.toggle()
    }
}
```

---

### 2. 词性标注生成

```swift
private func getGrammaticalIndicator(for word: Word) -> String {
    switch word.partOfSpeech {
    case .noun:
        // 名词显示性别
        if let mainForm = word.forms.first(where: { $0.isMainForm }),
           let gender = mainForm.gender {
            return "(\(gender == .masculine ? "m." : "f."))"
        }
        return "(n.)"

    case .verb:
        return "(v.)"

    case .adjective:
        return "(adj.)"

    case .adverb:
        return "(adv.)"

    default:
        return "(\(word.partOfSpeech.abbreviation))"
    }
}
```

---

### 3. 单词标题生成

```swift
private func getWordTitle(for word: Word) -> String {
    if word.partOfSpeech == .noun {
        // 名词显示带冠词的完整形式
        if let mainForm = word.forms.first(where: { $0.isMainForm }) {
            return mainForm.french  // 如 "la gomme"
        }
    }

    // 其他词性显示canonical
    return word.canonical
}
```

---

## 用户体验

### 1. 学习流程示例

```
用户打开应用
    ↓
进入UnitsView
    ├── 看到星星进度: 218 / 420
    ├── 获得每日登录奖励: +2⭐
    └── 选择 "Unité 1 : À l'école" ✓
         ↓
进入UniteDetailView
    └── 选择 "Les fournitures scolaires"
         ↓
进入SectionDetailView
    ├── 浏览单词列表
    ├── 获得浏览奖励: +5⭐
    └── 点击 "la gomme"
         ↓
进入WordDetailView
    ├── 查看橡皮图片
    ├── 点击图片显示单词卡片
    ├── 点击🔊播放发音
    ├── 左滑查看下一个单词 "le stylo"
    ├── 右滑返回上一个单词 "la gomme"
    └── 从左边缘右滑返回Section列表
```

---

### 2. 快捷导航示例

```
在WordDetailView中
    ↓
点击导航菜单 (⋯)
    ├── 选择 "Home" → 直接返回UnitsView
    ├── 选择 "Unité 1" → 返回UniteDetailView
    └── 选择 "Les fournitures" → 返回SectionDetailView
```

---

### 3. 练习模式入口

```
SectionDetailView中
    ↓
点击右上角 "练习 ▼"
    ├── 📷 看图选词 → PracticeView
    ├── 🎧 听力练习 → ListeningPracticeView
    ├── 📇 闪卡模式 → FlashcardView
    ├── ⌨️ 拼写练习 → SpellingPracticeView
    └── 🎮 配对游戏 → MatchingGameView
```

---

## 本地化

### 关键字符串

```swift
// UnitsView
"units.title" = "Units"
"units.unite.title" = "Unité %d : %@"
"units.sections.count" = "%d sections"
"units.unlock.required" = "需要 %d ⭐"
"units.import.button" = "Import Data"

// SectionDetailView
"section.button.practice" = "练习"
"section.practice.visual" = "看图选词"
"section.practice.listening" = "听力练习"
"section.practice.flashcard" = "闪卡模式"
"section.practice.spelling" = "拼写练习"
"section.practice.matching" = "配对游戏"
"section.words.count" = "%d words"

// WordDetailView
"word.detail.tap.hint" = "轻触查看单词"
```

---

## 文件结构

```
VocFr/
├── Views/
│   ├── Units/
│   │   ├── UnitsView.swift          // 单元列表（Level 1）
│   │   └── UniteDetailView (在UnitsView.swift中)
│   ├── Sections/
│   │   └── SectionView.swift        // Section详情（Level 3）
│   └── Words/
│       ├── WordView.swift           // 单词详情（Level 4）
│       └── WordRowView.swift        // 单词行组件
├── ViewModels/
│   └── WordDetailViewModel.swift    // 单词详情逻辑
├── Models/
│   └── Core/
│       └── Models.swift             // Unite, Section, Word等
├── Services/
│   ├── AudioPlayerManager.swift     // 音频播放
│   └── PointsManager.swift          // 星星奖励
└── {language}.lproj/
    └── Localizable.strings          // 本地化字符串
```

---

## 性能优化

### 1. 图片加载
- 使用缓存机制（SwiftUI自动处理）
- 检查图片存在性避免加载失败
- 占位符优雅降级

### 2. 音频播放
- 使用单例AudioPlayerManager
- 停止前一个音频再播放新的
- 异步加载音频文件

### 3. 列表渲染
- 使用LazyVStack延迟加载
- 只渲染可见区域
- 优化单元格复用

---

## 总结

### 已实现功能 ✅

- [x] 四级导航体系
- [x] 星星进度显示
- [x] 单元解锁系统
- [x] 每日登录奖励
- [x] 浏览Section奖励（5⭐）
- [x] 图片+音频展示
- [x] 单词卡片显示/隐藏
- [x] 左右滑动切换单词
- [x] 右滑返回手势
- [x] 单词洗牌模式
- [x] 快捷导航菜单
- [x] 7种语言本地化

### 学习路径设计 🎯

```
浏览学习（Study Mode）
    ↓
练习模式（Practice Modes）
    ├── 看图选词
    ├── 听力练习
    ├── 闪卡模式
    ├── 拼写练习
    └── 配对游戏
         ↓
测试评估（Test Mode）
    └── 综合能力测试
         ↓
游戏巩固（Game Mode）
    ├── Matching Game
    └── Hangman
```

---

**文档维护者**: Claude
**技术栈**: SwiftUI, SwiftData, AVFoundation
**最后更新**: 2025-11-16
