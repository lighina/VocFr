# Storybook System - 故事书系统详细说明

> **版本**: 2.0
> **创建日期**: 2025-11-17
> **最后更新**: 2025-11-18

---

## 目录

1. [系统概述](#系统概述)
2. [数据模型](#数据模型)
3. [解锁机制](#解锁机制)
4. [JSON数据结构](#json数据结构)
5. [UI设计](#ui设计)
6. [技术实现](#技术实现)
7. [内容创作指南](#内容创作指南)

---

## 系统概述

### 什么是Storybook？

**Storybook (故事书)** 是VocFr的阅读功能，为每个Unite提供与主题相关的法语小故事，帮助学习者：
- 📖 在真实语境中复习单词
- 🎯 提高法语阅读理解能力
- 🌟 体验沉浸式语言学习
- 🎨 通过图文并茂增强记忆

### 核心特性

- ✅ **每个Unite多本故事书**：每个Unite有2-3本故事书，紧密结合Unite主题和词汇
- 📚 **分层内容**：1本默认故事书（免费） + 1-2本额外故事书（付费）
- 🔓 **双重解锁方式**：完成Test（≥60%）自动解锁默认故事书 或 花费10💎解锁额外故事书
- 🔒 **渐进式访问**：只有已解锁的Unite的故事书才可见和可购买
- 🎧 **法语配音**：每页提供标准法语朗读
- 📱 **翻页阅读**：类似儿童绘本的阅读体验
- 🎯 **沉浸式学习**：纯法语阅读环境（数据保留中文字段供未来扩展）

---

## 数据模型

### 1. Storybook Model

```swift
@Model
class Storybook {
    @Attribute(.unique) var id: String
    var title: String              // 法语标题
    var titleInChinese: String     // 中文标题
    var uniteId: String            // 所属Unite ID
    var isUnlocked: Bool           // 解锁状态
    var isDefault: Bool            // 默认故事书（Test解锁）vs 额外故事书（宝石解锁）
    var requiredGems: Int          // 解锁所需宝石（默认故事书=0，额外故事书=10）
    var orderIndex: Int            // 显示顺序
    var coverImageName: String?    // 封面图片名称

    @Relationship(deleteRule: .cascade, inverse: \StoryPage.storybook)
    var pages: [StoryPage] = []    // 故事页面

    init(id: String, title: String, titleInChinese: String,
         uniteId: String, isUnlocked: Bool, isDefault: Bool = false,
         requiredGems: Int, orderIndex: Int, coverImageName: String? = nil)
}
```

### 2. StoryPage Model

```swift
@Model
class StoryPage {
    var pageNumber: Int           // 页码（从1开始）
    var contentFrench: String     // 法语文本
    var contentChinese: String    // 中文翻译
    var imageName: String?        // 页面插图名称
    var audioFileName: String?    // 音频文件名

    var storybook: Storybook?     // 所属故事书

    init(pageNumber: Int, contentFrench: String, contentChinese: String,
         imageName: String? = nil, audioFileName: String? = nil)
}
```

---

## 解锁机制

### 规则

#### 1. 前置条件：Unite必须已解锁
- **可见性规则**：只有已解锁Unite的故事书才会在列表中显示
- **购买限制**：未解锁Unite的故事书无法查看或购买
- **渐进式学习**：鼓励用户按照Unite顺序学习

#### 2. 默认故事书（isDefault=true）
- **解锁条件**：完成该Unite的Test且成绩 ≥ 60%
- **成本**：✅ 免费（requiredGems=0）
- **触发时机**：Test结果保存时自动检查和解锁
- **示例**：完成Unite 1 Test（成绩75%）→ 自动解锁《À l'école - Mon premier jour》

#### 3. 额外故事书（isDefault=false）
- **解锁条件**：手动用宝石解锁
- **成本**：**10💎**
- **触发时机**：用户在故事书列表中点击锁定的故事书
- **示例**：在已解锁Unite 1后，花费10💎解锁《Les couleurs de ma classe》

### 实现代码

#### 自动解锁：Test完成触发

```swift
// TestViewModel.swift
private func saveTestRecord(result: TestResult) {
    // ... 保存TestRecord和PracticeRecord ...

    // Award stars and gems
    let stars = result.score
    let gems = result.score / 10
    PointsManager.shared.awardStars(points: stars, ...)
    PointsManager.shared.awardGems(gems, ...)

    // Unlock default storybook if test passed (score >= 60)
    if result.score >= 60, let uniteId = unite?.id {
        unlockDefaultStorybook(for: uniteId, context: modelContext)
    }

    // Update WordProgress and track achievements
    // ...
}

/// Unlock default storybook for the given Unite
private func unlockDefaultStorybook(for uniteId: String, context: ModelContext) {
    // Find the default storybook for this unite
    let descriptor = FetchDescriptor<Storybook>(
        predicate: #Predicate<Storybook> { storybook in
            storybook.uniteId == uniteId &&
            storybook.isDefault == true &&
            storybook.isUnlocked == false
        }
    )

    do {
        let storybooks = try context.fetch(descriptor)
        if let defaultStorybook = storybooks.first {
            defaultStorybook.isUnlocked = true
            try context.save()
            print("📚 Unlocked default storybook: \(defaultStorybook.title) for Unite \(uniteId)")
        } else {
            print("📚 No locked default storybook found for Unite \(uniteId)")
        }
    } catch {
        print("❌ Failed to unlock default storybook: \(error)")
    }
}
```

#### 手动解锁：宝石购买

```swift
// StorybooksListView.swift
private func unlockStorybook(_ storybook: Storybook) {
    guard let userProgress = userProgress.first else {
        print("⚠️ UserProgress not found")
        return
    }

    // Check gems again
    if userProgress.totalGems >= storybook.requiredGems {
        // Deduct gems
        userProgress.totalGems -= storybook.requiredGems

        // Unlock storybook
        storybook.isUnlocked = true

        // Save changes
        do {
            try modelContext.save()
            print("📚 Unlocked storybook: \(storybook.title)")
        } catch {
            print("❌ Failed to save storybook unlock: \(error)")
        }
    } else {
        insufficientGems = true
    }
}
```

#### Unite过滤：只显示已解锁Unite的故事书

```swift
// StorybooksListView.swift
@Query(sort: \Storybook.orderIndex) private var allStorybooks: [Storybook]
@Query private var unites: [Unite]

/// Filter storybooks to only show those whose Unite is unlocked
private var availableStorybooks: [Storybook] {
    allStorybooks.filter { storybook in
        // Find the unite this storybook belongs to
        if let unite = unites.first(where: { $0.id == storybook.uniteId }) {
            return unite.isUnlocked
        }
        return false
    }
}
```

---

## JSON数据结构

### Storybooks.json

**实际实现的数据结构** (VocFr/Data/JSON/Storybooks.json):

**注意**: JSON数据中保留了中文字段（`titleInChinese`, `contentChinese`）以供未来功能扩展，但当前UI实现为**纯法语沉浸式阅读**，不显示中文翻译。

```json
{
  "storybooks": [
    {
      "id": "storybook_unite1_default",
      "title": "À l'école - Mon premier jour",
      "titleInChinese": "在学校 - 我的第一天",
      "uniteId": "unite1",
      "isUnlocked": false,
      "isDefault": true,
      "requiredGems": 0,
      "orderIndex": 1,
      "coverImageName": "storybook_school_cover",
      "pages": [
        {
          "pageNumber": 1,
          "contentFrench": "Bonjour ! Je m'appelle Sophie. Aujourd'hui, c'est mon premier jour à l'école.",
          "contentChinese": "你好！我叫索菲。今天是我在学校的第一天。",
          "imageName": "story_school_day1",
          "audioFileName": "story_unite1_page1.mp3"
        },
        {
          "pageNumber": 2,
          "contentFrench": "Voici ma classe. Je vois un bureau, une chaise et un tableau noir.",
          "contentChinese": "这是我的教室。我看到一张课桌、一把椅子和一块黑板。",
          "imageName": "story_school_classroom",
          "audioFileName": "story_unite1_page2.mp3"
        },
        {
          "pageNumber": 3,
          "contentFrench": "Dans mon sac, j'ai un cahier, un stylo, un crayon et une gomme.",
          "contentChinese": "在我的书包里，我有一个笔记本、一支钢笔、一支铅笔和一块橡皮。",
          "imageName": "story_school_bag",
          "audioFileName": "story_unite1_page3.mp3"
        },
        {
          "pageNumber": 4,
          "contentFrench": "Mon professeur est très gentil. Il s'appelle Monsieur Dupont.",
          "contentChinese": "我的老师非常和蔼。他叫杜邦先生。",
          "imageName": "story_school_teacher",
          "audioFileName": "story_unite1_page4.mp3"
        },
        {
          "pageNumber": 5,
          "contentFrench": "À la récréation, je joue avec mes amis dans la cour.",
          "contentChinese": "课间休息时，我和朋友们在操场上玩耍。",
          "imageName": "story_school_playground",
          "audioFileName": "story_unite1_page5.mp3"
        },
        {
          "pageNumber": 6,
          "contentFrench": "J'aime beaucoup l'école ! À demain !",
          "contentChinese": "我非常喜欢学校！明天见！",
          "imageName": "story_school_goodbye",
          "audioFileName": "story_unite1_page6.mp3"
        }
      ]
    },
    {
      "id": "storybook_unite1_extra1",
      "title": "Les couleurs de ma classe",
      "titleInChinese": "我的教室的颜色",
      "uniteId": "unite1",
      "isUnlocked": false,
      "isDefault": false,
      "requiredGems": 10,
      "orderIndex": 2,
      "coverImageName": "storybook_colors_cover",
      "pages": [
        {
          "pageNumber": 1,
          "contentFrench": "Ma classe est très colorée !",
          "contentChinese": "我的教室五颜六色！",
          "imageName": "story_colors_classroom",
          "audioFileName": "story_colors_page1.mp3"
        },
        {
          "pageNumber": 2,
          "contentFrench": "Le tableau est noir. Les craies sont blanches.",
          "contentChinese": "黑板是黑色的。粉笔是白色的。",
          "imageName": "story_colors_blackboard",
          "audioFileName": "story_colors_page2.mp3"
        },
        {
          "pageNumber": 3,
          "contentFrench": "Mon cahier est bleu. Mon stylo est rouge.",
          "contentChinese": "我的笔记本是蓝色的。我的钢笔是红色的。",
          "imageName": "story_colors_notebook",
          "audioFileName": "story_colors_page3.mp3"
        },
        {
          "pageNumber": 4,
          "contentFrench": "Les murs sont jaunes. La porte est verte.",
          "contentChinese": "墙壁是黄色的。门是绿色的。",
          "imageName": "story_colors_walls",
          "audioFileName": "story_colors_page4.mp3"
        },
        {
          "pageNumber": 5,
          "contentFrench": "J'adore toutes ces couleurs !",
          "contentChinese": "我喜欢所有这些颜色！",
          "imageName": "story_colors_rainbow",
          "audioFileName": "story_colors_page5.mp3"
        }
      ]
    }
  ]
}
```

**数据结构说明**：

1. **根对象包含storybooks数组**：整个JSON文件使用`{"storybooks": [...]}`结构
2. **id命名规范**：
   - 默认故事书：`storybook_unite{N}_default`
   - 额外故事书：`storybook_unite{N}_extra{M}`
3. **isDefault字段**：区分默认（true）和额外（false）故事书
4. **requiredGems**：默认故事书=0，额外故事书=10
5. **页面数量**：默认故事书6页，额外故事书5页（可根据内容调整）

---

## UI设计

### 1. StorybookListView (故事书列表)

```
┌─────────────────────────────────────┐
│  📚 Storybooks                      │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────────────────────┐ │
│  │ [封面图] À l'école            │ │
│  │         在学校 - 我的第一天    │ │
│  │         ✅ 已解锁             │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ [封面图] C'est la fête        │ │
│  │         庆祝 - 玛丽的生日      │ │
│  │         🔒 需要10💎           │ │
│  └───────────────────────────────┘ │
│                                     │
└─────────────────────────────────────┘
```

```swift
struct StorybookListView: View {
    @Query private var storybooks: [Storybook]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List(storybooks.sorted(by: { $0.orderIndex < $1.orderIndex })) { storybook in
            StorybookCardView(storybook: storybook)
                .onTapGesture {
                    if storybook.isUnlocked {
                        openStorybook(storybook)
                    } else {
                        showUnlockAlert(storybook)
                    }
                }
        }
        .navigationTitle("Storybooks")
    }
}
```

### 2. StorybookReaderView (阅读界面)

```
┌─────────────────────────────────────┐
│  ← [1/4]                       🔊   │
├─────────────────────────────────────┤
│                                     │
│         [插图]                       │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  C'est mon premier jour à l'école.  │
│                                     │
│  (沉浸式法语阅读，无中文翻译)        │
│                                     │
├─────────────────────────────────────┤
│        ◀  1 / 4  ▶                 │
└─────────────────────────────────────┘
```

```swift
struct StorybookReaderView: View {
    let storybook: Storybook
    @State private var currentPage = 0

    private var pages: [StoryPage] {
        storybook.pages.sorted(by: { $0.pageNumber < $1.pageNumber })
    }

    var body: some View {
        VStack {
            // Top bar
            HStack {
                Button("Back") { dismiss() }
                Spacer()
                Text("\(currentPage + 1)/\(pages.count)")
                Spacer()
                Button(action: playAudio) {
                    Image(systemName: "speaker.wave.2.fill")
                }
            }
            .padding()

            // Story content
            ScrollView {
                VStack(spacing: 24) {
                    // Image
                    if let imageName = pages[currentPage].imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                    }

                    // French text (immersive learning)
                    Text(pages[currentPage].contentFrench)
                        .font(.custom("EB Garamond", size: 22))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.8), radius: 2)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.black.opacity(0.7))
                        )
                }
            }

            // Page navigation
            HStack {
                Button(action: previousPage) {
                    Image(systemName: "chevron.left")
                }
                .disabled(currentPage == 0)

                Spacer()

                Text("\(currentPage + 1) / \(pages.count)")

                Spacer()

                Button(action: nextPage) {
                    Image(systemName: "chevron.right")
                }
                .disabled(currentPage == pages.count - 1)
            }
            .padding()
        }
    }
}
```

### 3. 解锁弹窗

```swift
.alert("Unlock Storybook?", isPresented: $showUnlockAlert) {
    Button("Cancel", role: .cancel) { }
    Button("Unlock (10💎)") {
        unlockWithGems()
    }
} message: {
    Text("Spend 10 gems to unlock '\(storybook.title)'?")
}
```

---

## 技术实现

### 1. JSON加载

```swift
// StorybookLoader.swift
class StorybookLoader {
    static func loadStorybooks(into context: ModelContext) throws {
        guard let url = Bundle.main.url(forResource: "Storybooks", withExtension: "json") else {
            throw LoaderError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let storybooksData = try JSONDecoder().decode([StorybookData].self, from: data)

        for storybookData in storybooksData {
            let storybook = Storybook(
                id: storybookData.id,
                title: storybookData.title,
                titleInChinese: storybookData.titleInChinese,
                uniteId: storybookData.uniteId,
                isUnlocked: storybookData.isUnlocked,
                requiredGems: storybookData.requiredGems,
                orderIndex: storybookData.orderIndex,
                coverImageName: storybookData.coverImageName
            )

            context.insert(storybook)

            for pageData in storybookData.pages {
                let page = StoryPage(
                    pageNumber: pageData.pageNumber,
                    contentFrench: pageData.contentFrench,
                    contentChinese: pageData.contentChinese,
                    imageName: pageData.imageName,
                    audioFileName: pageData.audioFileName
                )
                page.storybook = storybook
                context.insert(page)
            }
        }

        try context.save()
    }
}
```

### 2. 音频播放

```swift
import AVFoundation

class StorybookAudioPlayer: ObservableObject {
    private var audioPlayer: AVAudioPlayer?

    func play(audioFileName: String) {
        guard let url = Bundle.main.url(forResource: audioFileName, withExtension: nil) else {
            print("❌ Audio file not found: \(audioFileName)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("❌ Failed to play audio: \(error)")
        }
    }

    func stop() {
        audioPlayer?.stop()
    }
}
```

---

## 内容创作指南

### 故事书设计原则

1. **词汇复用率高**：
   - 至少使用该Unite 80%的核心词汇
   - 示例：Unite 1 (学校主题) → 故事必须包含 bureau, chaise, tableau 等

2. **句子简单易懂**：
   - 使用现在时为主
   - 句子长度：5-10个单词
   - 避免复杂语法结构

3. **情节连贯有趣**：
   - 4-6页为宜（太短缺乏情节，太长容易疲劳）
   - 有起承转合的小故事
   - 适合儿童/初学者的内容

4. **图文配合**：
   - 每页配图说明关键场景
   - 图片风格统一（建议使用AI生成或插画）

### 示例：Unite 1 故事创作过程

**Step 1: 选择主题**
- Unite 1词汇：bureau, chaise, tableau, professeur, élève...
- 主题：第一天上学的经历

**Step 2: 构思情节**
```
Page 1: 介绍 - 今天是第一天上学
Page 2: 观察 - 看到教室里的物品
Page 3: 互动 - 老师打招呼
Page 4: 结尾 - 喜欢学校
```

**Step 3: 编写文本**
```
Page 1:
- FR: C'est mon premier jour à l'école.
- ZH: 这是我在学校的第一天。

Page 2:
- FR: Je vois un bureau, une chaise et un tableau.
- ZH: 我看到一张课桌、一把椅子和一块黑板。

Page 3:
- FR: Le professeur dit: "Bonjour les enfants!"
- ZH: 老师说："孩子们，你们好！"

Page 4:
- FR: J'aime mon école!
- ZH: 我喜欢我的学校！
```

**Step 4: 配音录制**
- 使用标准法语发音
- 语速适中，吐字清晰
- 格式：MP3, 码率128kbps

---

## 资源清单

### 每个Storybook需要的资源

| 资源类型 | 数量 | 命名规范 | 示例 | 存储路径 |
|---------|------|----------|------|----------|
| 封面图片 | 1张 | `cover.png` | `cover.png` | `VocFr/Resources/Images/Storybooks/Unite{N}/Book{M}/` |
| 页面插图 | 4-10张 | `page{N}.png` | `page1.png`, `page2.png` | `VocFr/Resources/Images/Storybooks/Unite{N}/Book{M}/` |
| 页面音频 | 4-10个 | `story_unite{N}_page{M}.mp3` | `story_unite1_page1.mp3` | `VocFr/Resources/Audio/Storybooks/Unite{N}/Book{M}/` |
| JSON数据 | 1个 | 在 `Storybooks.json` 中添加 | - | `VocFr/Data/JSON/Storybooks.json` |

### 资源组织结构示例

```
VocFr/
├── Resources/
│   ├── Audio/
│   │   ├── Words/              # 单词音频
│   │   │   └── Unite1/
│   │   │       └── Section1/
│   │   │           └── u1s1-balle.mp3
│   │   └── Storybooks/         # 故事书音频
│   │       ├── Unite1/
│   │       │   ├── Book1/      # 默认故事书
│   │       │   │   ├── story_unite1_page1.mp3
│   │       │   │   ├── story_unite1_page2.mp3
│   │       │   │   └── ...
│   │       │   └── Book2/      # 额外故事书
│   │       │       ├── story_unite1_page1.mp3
│   │       │       └── ...
│   │       └── Unite2/
│   │           └── Book1/
│   │               └── ...
│   └── Images/
│       └── Storybooks/
│           ├── Unite1/
│           │   ├── Book1/
│           │   │   ├── cover.png
│           │   │   ├── page1.png
│           │   │   ├── page2.png
│           │   │   └── ...
│           │   └── Book2/
│           │       ├── cover.png
│           │       └── ...
│           └── Unite2/
│               └── ...
└── Data/
    └── JSON/
        └── Storybooks.json
```

### 命名规范说明

1. **图片命名简化**：
   - 封面：统一使用 `cover.png`
   - 页面：使用 `page{N}.png`（N从1开始）
   - 优势：简洁明了，易于管理

2. **音频命名保持描述性**：
   - 格式：`story_unite{N}_page{M}.mp3`
   - 优势：音频文件可能跨项目使用，描述性命名便于识别

3. **路径组织原则**：
   - 按 Unite → Book 层级组织
   - 每个Book独立文件夹，资源隔离
   - 便于批量导入和管理

---

## 实施计划

### Phase 1: 基础架构 ✅ 已完成
- [x] 创建Storybook和StoryPage模型（添加isDefault字段）
- [x] 设计JSON数据结构（根对象包含storybooks数组）
- [x] 实现StorybookDataLoader加载器
- [x] 集成到FrenchVocabularySeeder数据导入流程
- [x] 编写Unite 1完整JSON数据（2本故事书，共11页）

### Phase 2: UI开发 ✅ 已完成
- [x] 创建StorybooksListView（含Unite过滤）
- [x] 创建StorybookReaderView（翻页阅读）
- [x] 实现StorybookCard组件
- [x] 添加解锁弹窗（宝石余额检查）
- [x] 实现Unite-based可见性过滤

### Phase 3: 解锁逻辑 ✅ 已完成
- [x] TestViewModel自动解锁默认故事书（Test ≥ 60%）
- [x] StorybooksListView手动解锁额外故事书（花费10💎）
- [x] 宝石余额检查和扣除逻辑
- [x] Unite解锁状态过滤
- [x] 错误处理和用户反馈

### Phase 4: 内容制作 🚧 部分完成
- [x] Unite 1默认故事创作：《À l'école - Mon premier jour》（6页）
- [x] Unite 1额外故事创作：《Les couleurs de ma classe》（5页）
- [ ] Unite 2-6故事创作
- [ ] 插图设计/生成（当前使用placeholder图片名称）
- [ ] 音频录制（当前使用placeholder音频文件名）

### Phase 5: 测试优化 ⏳ 待测试
- [ ] 端到端解锁流程测试
- [ ] 音频播放功能测试
- [ ] 多Unite故事书交互测试
- [ ] 用户体验优化
- [ ] 性能优化

**当前状态**：
- ✅ 核心功能已完成：模型、数据加载、UI、解锁逻辑
- ✅ Unite 1内容完整：2本故事书，11页完整文本
- 🚧 待补充：插图资源、音频文件
- ⏳ 待开发：Unite 2-6 故事书内容

---

## 常见问题

### Q1: 为什么故事书需要解锁？
A: 解锁机制提供了两方面价值：
1. **学习激励**：完成Test获得故事书作为奖励
2. **货币消费**：为宝石系统提供有价值的消费途径

### Q2: 故事书的难度如何控制？
A: 遵循以下原则：
- 使用该Unite已学词汇（80%+）
- 简单语法结构（现在时为主）
- 短句为主（5-10词/句）
- 提供中文对照降低理解难度

### Q3: 如何确保音频质量？
A: 建议：
- 使用专业法语母语者录制
- 或使用高质量TTS（如Google TTS, Azure TTS）
- 语速：100-120 words/min（适合初学者）
- 格式：MP3, 128kbps, 44.1kHz

### Q4: 故事书数量规划？
A: 计划：
- 每个Unite 1本故事书（必备）
- 每本4-6页（适中长度）
- 共6本（对应6个Unite）
- 未来可扩展：难度分级、主题系列等

---

> **版权说明**: 故事内容应为原创或获得授权使用，插图可使用AI生成工具（如Midjourney, DALL-E）创作。
