# Storybook System - 故事书系统详细说明

> **版本**: 1.0
> **创建日期**: 2025-11-17
> **最后更新**: 2025-11-17

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

- ✅ **每个Unite一本故事书**：紧密结合Unite主题和词汇
- 🔓 **双重解锁方式**：完成Test自动解锁 或 花费10💎解锁
- 🎧 **法语配音**：每页提供标准法语朗读
- 🇨🇳 **中文对照**：逐页提供中文翻译
- 📱 **翻页阅读**：类似儿童绘本的阅读体验

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
    var requiredGems: Int          // 解锁所需宝石（非本Unite解锁）
    var orderIndex: Int            // 显示顺序
    var coverImageName: String?    // 封面图片名称

    @Relationship(deleteRule: .cascade, inverse: \StoryPage.storybook)
    var pages: [StoryPage] = []    // 故事页面

    init(id: String, title: String, titleInChinese: String,
         uniteId: String, isUnlocked: Bool, requiredGems: Int,
         orderIndex: Int, coverImageName: String? = nil)
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

1. **本Unite故事书**：
   - 完成该Unite的Test → 自动解锁 ✅ 免费
   - 示例：完成Unite 1 Test → 解锁《À l'école》故事书

2. **其他Unite故事书**：
   - 需要花费 **10💎** 解锁
   - 示例：在Unite 1，想读Unite 2故事书 → 花费10💎

### 实现代码

```swift
// TestViewModel.swift - Test完成后自动解锁故事书
func completeTest(result: TestResult, modelContext: ModelContext) {
    // ... 保存结果 ...

    // 解锁本Unite的故事书
    if let uniteId = unite?.id {
        unlockStorybookForUnite(uniteId: uniteId, context: modelContext)
    }
}

private func unlockStorybookForUnite(uniteId: String, context: ModelContext) {
    let descriptor = FetchDescriptor<Storybook>(
        predicate: #Predicate { $0.uniteId == uniteId }
    )

    if let storybook = try? context.fetch(descriptor).first {
        if !storybook.isUnlocked {
            storybook.isUnlocked = true
            try? context.save()
            print("📚 Storybook '\(storybook.title)' unlocked!")
        }
    }
}
```

```swift
// PointsManager.swift - 用宝石解锁
func unlockStorybook(_ storybook: Storybook, modelContext: ModelContext) -> Bool {
    guard !storybook.isUnlocked else {
        print("ℹ️ \(storybook.title) is already unlocked")
        return false
    }

    if spendGems(storybook.requiredGems, modelContext: modelContext,
                 for: "Unlock \(storybook.title)") {
        storybook.isUnlocked = true
        print("🎉 \(storybook.title) unlocked with \(storybook.requiredGems)💎!")
        try? modelContext.save()
        return true
    }

    return false
}
```

---

## JSON数据结构

### Storybooks.json

```json
[
  {
    "id": "storybook_unite1",
    "title": "À l'école - Mon premier jour",
    "titleInChinese": "在学校 - 我的第一天",
    "uniteId": "unite1",
    "isUnlocked": false,
    "requiredGems": 10,
    "orderIndex": 1,
    "coverImageName": "storybook_unite1_cover",
    "pages": [
      {
        "pageNumber": 1,
        "contentFrench": "C'est mon premier jour à l'école.",
        "contentChinese": "这是我在学校的第一天。",
        "imageName": "storybook_unite1_page1",
        "audioFileName": "storybook_unite1_page1.mp3"
      },
      {
        "pageNumber": 2,
        "contentFrench": "Je vois un bureau, une chaise et un tableau.",
        "contentChinese": "我看到一张课桌、一把椅子和一块黑板。",
        "imageName": "storybook_unite1_page2",
        "audioFileName": "storybook_unite1_page2.mp3"
      },
      {
        "pageNumber": 3,
        "contentFrench": "Le professeur dit: \"Bonjour les enfants!\"",
        "contentChinese": "老师说："孩子们，你们好！"",
        "imageName": "storybook_unite1_page3",
        "audioFileName": "storybook_unite1_page3.mp3"
      },
      {
        "pageNumber": 4,
        "contentFrench": "J'aime mon école!",
        "contentChinese": "我喜欢我的学校！",
        "imageName": "storybook_unite1_page4",
        "audioFileName": "storybook_unite1_page4.mp3"
      }
    ]
  },
  {
    "id": "storybook_unite2",
    "title": "C'est la fête - L'anniversaire de Marie",
    "titleInChinese": "庆祝 - 玛丽的生日",
    "uniteId": "unite2",
    "isUnlocked": false,
    "requiredGems": 10,
    "orderIndex": 2,
    "coverImageName": "storybook_unite2_cover",
    "pages": [...]
  },
  {
    "id": "storybook_unite3",
    "title": "Mon chez-moi - La maison de Lucas",
    "titleInChinese": "我的家 - 卢卡斯的房子",
    "uniteId": "unite3",
    "isUnlocked": false,
    "requiredGems": 10,
    "orderIndex": 3,
    "coverImageName": "storybook_unite3_cover",
    "pages": [...]
  }
]
```

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
│  ← [1/4]                    🔊 📖  │
├─────────────────────────────────────┤
│                                     │
│         [插图]                       │
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  C'est mon premier jour à l'école.  │
│                                     │
│  这是我在学校的第一天。               │
│                                     │
├─────────────────────────────────────┤
│        ◀  1 / 4  ▶                 │
└─────────────────────────────────────┘
```

```swift
struct StorybookReaderView: View {
    let storybook: Storybook
    @State private var currentPage = 0
    @State private var showTranslation = false

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
                Button(action: { showTranslation.toggle() }) {
                    Image(systemName: "text.bubble")
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

                    // French text
                    Text(pages[currentPage].contentFrench)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()

                    // Chinese translation (toggleable)
                    if showTranslation {
                        Text(pages[currentPage].contentChinese)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
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

| 资源类型 | 数量 | 命名规范 | 示例 |
|---------|------|----------|------|
| 封面图片 | 1张 | `storybook_unite{N}_cover.png` | `storybook_unite1_cover.png` |
| 页面插图 | 4-6张 | `storybook_unite{N}_page{M}.png` | `storybook_unite1_page1.png` |
| 页面音频 | 4-6个 | `storybook_unite{N}_page{M}.mp3` | `storybook_unite1_page1.mp3` |
| JSON数据 | 1个 | 在 `Storybooks.json` 中添加 | - |

---

## 实施计划

### Phase 1: 基础架构 ✅
- [x] 创建Storybook和StoryPage模型
- [x] 设计JSON数据结构
- [x] 实现PointsManager解锁功能
- [x] 编写示例JSON数据

### Phase 2: UI开发 ⏳
- [ ] 创建StorybookListView
- [ ] 创建StorybookReaderView
- [ ] 实现翻页动画
- [ ] 添加解锁弹窗

### Phase 3: 内容制作 ⏳
- [ ] Unite 1故事创作
- [ ] Unite 2故事创作
- [ ] Unite 3故事创作
- [ ] 插图设计/生成
- [ ] 音频录制

### Phase 4: 测试优化 ⏳
- [ ] 解锁逻辑测试
- [ ] 音频播放测试
- [ ] 用户体验优化
- [ ] 性能优化

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
