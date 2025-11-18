# VocFr 开发者指南

为 VocFr 项目做贡献或维护项目的完整指南

---

## 📋 目录

- [项目概述](#项目概述)
- [技术栈](#技术栈)
- [项目架构](#项目架构)
- [开发环境设置](#开发环境设置)
- [代码规范](#代码规范)
- [数据管理](#数据管理)
- [测试](#测试)
- [部署](#部署)
- [贡献指南](#贡献指南)

---

## 🎯 项目概述

VocFr 是一款基于 SwiftUI 和 SwiftData 的现代化法语学习应用，采用 MVVM 架构，支持 iOS 17+。

### 核心功能

- 系统化词汇学习（Unite → Section → Words）
- 测试评估系统（星星奖励）
- 游戏化学习（宝石奖励）
- 互动故事书（双语/纯法语）
- 7 种界面语言支持

### 项目特点

- 纯本地应用，无需联网
- 日式极简美学设计
- 完整的自动化数据导入工具
- iPad 优化（双页布局）

---

## 🛠️ 技术栈

### 核心框架

- **SwiftUI**: iOS 原生 UI 框架
- **SwiftData**: 数据持久化（iOS 17+）
- **Combine**: 响应式编程
- **AVFoundation**: 音频播放

### 开发工具

- **Xcode**: 15.0+
- **Swift**: 5.9+
- **Python**: 3.8+ (数据导入工具)

### 依赖库

- 无第三方依赖（纯原生实现）

---

## 🏗️ 项目架构

### MVVM 架构

```
┌─────────────────────────────────────┐
│              View                   │  SwiftUI Views
│  (StorybookReaderView.swift)        │
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│           ViewModel                 │  @Observable Classes
│  (StorybookReaderViewModel.swift)   │  (计划添加)
└──────────────┬──────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│            Model                    │  SwiftData Models
│  (Storybook.swift, Word.swift)      │
└─────────────────────────────────────┘
               │
               ↓
┌─────────────────────────────────────┐
│          Services                   │  Business Logic
│  (GameDataLoader.swift)             │
└─────────────────────────────────────┘
```

### 目录结构

```
VocFr/
├── VocFr/                          # 应用代码
│   ├── VocFrApp.swift             # App 入口
│   ├── Models/                     # 数据模型
│   │   ├── Unite.swift
│   │   ├── Section.swift
│   │   ├── Word.swift
│   │   ├── Storybook.swift
│   │   └── UserProgress.swift
│   ├── Views/                      # UI 视图
│   │   ├── Main/                   # 主界面
│   │   │   └── MainAppView.swift
│   │   ├── Units/                  # 学习模块
│   │   ├── Games/                  # 游戏模块
│   │   └── Storybooks/            # 故事书模块
│   ├── Services/                   # 业务逻辑
│   │   ├── Data/
│   │   │   └── GameDataLoader.swift
│   │   └── Audio/
│   │       └── AudioManager.swift
│   ├── Data/                       # 数据文件
│   │   └── JSON/
│   │       ├── Unite1.json
│   │       └── Storybooks.json
│   └── Resources/                  # 资源文件
│       ├── Images/
│       ├── Audio/
│       └── Localizations/
├── Scripts/                        # 自动化脚本
│   ├── Vocabulary/                 # 词汇导入
│   └── Storybooks/                 # 故事书导入
├── docs/                           # 文档
│   ├── user/                       # 用户文档
│   ├── developer/                  # 开发者文档
│   └── specifications/             # 功能规范
└── archive/                        # 归档文档
```

---

## 🚀 开发环境设置

### 前置要求

1. **macOS**: Sonoma 14.0+
2. **Xcode**: 15.0+
3. **iOS 模拟器**: iOS 17.0+

### 克隆项目

```bash
git clone https://github.com/yourusername/VocFr.git
cd VocFr
```

### 打开项目

```bash
open VocFr.xcodeproj
```

### 运行项目

1. 选择目标设备（iPhone 或 iPad 模拟器）
2. 按 `Cmd + R` 运行
3. 首次运行会自动导入数据

### Python 环境（可选）

如果需要使用数据导入工具：

```bash
# 确保 Python 3.8+
python3 --version

# 无需安装额外依赖（仅使用标准库）
```

---

## 📝 代码规范

### Swift 代码风格

遵循 [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

**命名规范**：

```swift
// ✅ 正确
class StorybookReaderViewModel: ObservableObject {
    @Published var currentPage: Int = 0

    func nextPage() {
        currentPage += 1
    }
}

// ❌ 错误
class storybookReader {
    var curr_page = 0

    func NextPage() {
        curr_page = curr_page + 1
    }
}
```

**SwiftUI 视图**：

```swift
// ✅ 正确
struct StorybookReaderView: View {
    let storybook: Storybook
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(storybook.pages) { page in
                PageView(page: page)
            }
        }
        .tabViewStyle(.page)
    }
}

// ❌ 错误 - 复杂逻辑应该提取到方法
struct BadView: View {
    var body: some View {
        VStack {
            if condition1 {
                if condition2 {
                    if condition3 {
                        // 嵌套太深
                    }
                }
            }
        }
    }
}
```

**SwiftData 模型**：

```swift
// ✅ 正确
@Model
final class Word {
    @Attribute(.unique) var id: String
    var canonical: String
    var chinese: String

    init(id: String, canonical: String, chinese: String) {
        self.id = id
        self.canonical = canonical
        self.chinese = chinese
    }
}
```

### 注释规范

**文档注释**：

```swift
/// 加载故事书数据到 SwiftData context
///
/// - Parameters:
///   - context: SwiftData 的 ModelContext
/// - Throws: 数据加载错误
/// - Note: 支持增量更新，不会覆盖现有数据
static func loadStorybooksIntoContext(_ context: ModelContext) throws {
    // 实现...
}
```

**代码注释**：

```swift
// MARK: - Audio Management

/// 播放指定页面的音频
private func playAudio(for page: StorybookPage) {
    // 构建音频文件名
    let audioName = page.audioFileName

    // 从 Bundle 加载
    guard let url = Bundle.main.url(forResource: audioName, withExtension: "mp3") else {
        return
    }

    // 播放音频
    audioManager.play(url: url)
}
```

### Git 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/)：

```bash
# 功能
git commit -m "feat: Add double-page layout for iPad landscape mode"

# 修复
git commit -m "fix: Resolve audio playback issue on iOS 17"

# 文档
git commit -m "docs: Update README with installation instructions"

# 样式
git commit -m "style: Apply Japanese minimalist design to storybook UI"

# 重构
git commit -m "refactor: Extract audio logic to AudioManager service"

# 测试
git commit -m "test: Add unit tests for vocabulary import script"

# 构建
git commit -m "chore: Update Xcode project settings for iOS 17"
```

---

## 💾 数据管理

### SwiftData 模型

**创建模型**：

```swift
import SwiftData

@Model
final class Storybook {
    @Attribute(.unique) var id: String
    var title: String
    var uniteId: String
    @Relationship(deleteRule: .cascade) var pages: [StorybookPage]

    init(id: String, title: String, uniteId: String) {
        self.id = id
        self.title = title
        self.uniteId = uniteId
        self.pages = []
    }
}
```

**查询数据**：

```swift
@Query(sort: \Storybook.orderIndex) var storybooks: [Storybook]

// 或使用 FetchDescriptor
let descriptor = FetchDescriptor<Storybook>(
    predicate: #Predicate { $0.uniteId == "unite1" },
    sortBy: [SortDescriptor(\.orderIndex)]
)
let storybooks = try context.fetch(descriptor)
```

**更新数据**：

```swift
// 插入
context.insert(newStorybook)

// 更新
storybook.isUnlocked = true

// 删除
context.delete(storybook)

// 保存
try context.save()
```

### JSON 数据格式

**Unite 数据** (`UniteX.json`):

```json
{
  "id": "unite1",
  "number": 1,
  "title": "À l'école",
  "titleInChinese": "在学校",
  "isUnlocked": true,
  "requiredStars": 0,
  "requiredGems": 0,
  "sections": [
    {
      "id": "section1_1",
      "name": "Dans la classe",
      "orderIndex": 1,
      "words": [
        {
          "canonical": "livre",
          "chinese": "书",
          "partOfSpeech": "noun",
          "genderOrPos": "masculine",
          "category": "school_objects",
          "elision": false
        }
      ]
    }
  ]
}
```

**Storybook 数据** (`Storybooks.json`):

```json
[
  {
    "id": "storybook_unite1_book1",
    "title": "Le Premier Jour d'École",
    "titleInChinese": "第一天上学",
    "uniteId": "unite1",
    "isUnlocked": false,
    "isDefault": true,
    "requiredGems": 0,
    "orderIndex": 1,
    "coverImageName": "storybook_unite1_book1_cover",
    "pages": [
      {
        "pageNumber": 1,
        "imageName": "storybook_unite1_book1_page1",
        "audioFileName": "story_unite1_book1_page1",
        "content": "C'est le premier jour d'école.",
        "contentChinese": "这是第一天上学。"
      }
    ]
  }
]
```

### 数据导入工具

**词汇导入**：

```bash
python Scripts/Vocabulary/import_vocabulary.py \
    --source vocabulary_unite4.csv \
    --output VocFr/Data/JSON/Unite4.json
```

**故事书导入**：

```bash
python Scripts/Storybooks/import_storybook.py \
    --source storybook_resources/ \
    --unite 1 \
    --book 3 \
    --title-fr "Le Petit Prince" \
    --title-zh "小王子"
```

详见：
- [词汇导入指南](../../Scripts/Vocabulary/VOCABULARY_IMPORT_GUIDE.md)
- [故事书导入指南](../../Scripts/Storybooks/STORYBOOK_IMPORT_GUIDE.md)

---

## 🧪 测试

### 单元测试

**创建测试**：

```swift
import XCTest
@testable import VocFr

final class GameDataLoaderTests: XCTestCase {
    func testLoadUnites() throws {
        let unites = try GameDataLoader.loadUnites()
        XCTAssertEqual(unites.count, 6)
        XCTAssertEqual(unites[0].id, "unite1")
    }

    func testLoadStorybooks() throws {
        let storybooks = try GameDataLoader.loadStorybooks()
        XCTAssertFalse(storybooks.isEmpty)
    }
}
```

**运行测试**：

```bash
# 在 Xcode 中
Cmd + U

# 或命令行
xcodebuild test -scheme VocFr -destination 'platform=iOS Simulator,name=iPhone 15'
```

### UI 测试

```swift
final class VocFrUITests: XCTestCase {
    func testNavigateToStorybook() throws {
        let app = XCUIApplication()
        app.launch()

        app.buttons["Storybook"].tap()
        XCTAssertTrue(app.navigationBars["Storybooks"].exists)
    }
}
```

### 数据导入测试

```bash
# 验证模式（不保存）
python Scripts/Vocabulary/import_vocabulary.py \
    --source test.csv \
    --output test.json \
    --validate-only

# 预览模式（不写入）
python Scripts/Vocabulary/import_vocabulary.py \
    --source test.csv \
    --output test.json \
    --dry-run
```

---

## 🚢 部署

### 构建发布版本

1. **更新版本号**：
   ```
   Xcode → Target → General → Version
   Version: 1.0
   Build: 1
   ```

2. **清理构建**：
   ```bash
   Cmd + Shift + K
   ```

3. **归档**：
   ```
   Product → Archive
   ```

4. **导出 IPA**：
   ```
   Organizer → Distribute App → App Store Connect
   ```

### App Store 提交

1. **准备材料**：
   - App 图标（1024x1024）
   - 截图（各种设备尺寸）
   - 应用描述
   - 隐私政策

2. **上传**：
   - 使用 Xcode Organizer
   - 或使用 Transporter 应用

3. **审核**：
   - 提交审核
   - 等待 Apple 审核（通常 1-3 天）

### TestFlight 测试

```bash
# 上传到 TestFlight
Product → Archive → Distribute App → TestFlight

# 添加测试用户
App Store Connect → TestFlight → 添加测试员
```

---

## 🤝 贡献指南

### 开始贡献

1. **Fork 项目**：
   ```bash
   # 在 GitHub 点击 Fork
   ```

2. **克隆到本地**：
   ```bash
   git clone https://github.com/yourusername/VocFr.git
   cd VocFr
   ```

3. **创建功能分支**：
   ```bash
   git checkout -b feature/amazing-feature
   ```

4. **提交更改**：
   ```bash
   git add .
   git commit -m "feat: Add amazing feature"
   ```

5. **推送分支**：
   ```bash
   git push origin feature/amazing-feature
   ```

6. **创建 Pull Request**：
   - 在 GitHub 创建 PR
   - 描述更改内容
   - 等待 review

### Pull Request 规范

**PR 标题**：
```
feat: Add voice recording feature
fix: Resolve memory leak in audio player
docs: Update developer guide
```

**PR 描述模板**：
```markdown
## 变更类型
- [ ] 新功能
- [ ] Bug 修复
- [ ] 文档更新
- [ ] 代码重构

## 变更说明
简要描述此 PR 的内容和目的

## 测试
- [ ] 添加了单元测试
- [ ] 添加了 UI 测试
- [ ] 手动测试通过

## 截图
如果有 UI 变更，添加截图

## 相关 Issue
Closes #123
```

### 代码审查

**审查要点**：
- ✅ 代码符合规范
- ✅ 有适当的注释
- ✅ 通过所有测试
- ✅ 无明显性能问题
- ✅ UI 符合设计规范

---

## 📚 相关文档

### 用户文档
- [用户使用手册](../user/USER_GUIDE.md)
- [快速入门指南](../user/QUICK_START.md)
- [功能详细介绍](../user/FEATURES_OVERVIEW.md)
- [常见问题](../user/FAQ.md)

### 功能规范
- [游戏模式规范](../specifications/GAME_MODE_SPECIFICATION.md)
- [语言规范](../specifications/LANGUAGE_SPECIFICATION.md)
- [奖励系统规范](../specifications/REWARDS_SYSTEM_SPECIFICATION.md)
- [故事书规范](../specifications/STORYBOOK_SPECIFICATION.md)
- [学习模式规范](../specifications/STUDY_MODE_SPECIFICATION.md)
- [测试模式规范](../specifications/TEST_MODE_SPECIFICATION.md)

### 操作指南
- [词汇导入指南](../../Scripts/Vocabulary/VOCABULARY_IMPORT_GUIDE.md)
- [故事书导入指南](../../Scripts/Storybooks/STORYBOOK_IMPORT_GUIDE.md)
- [AI 辅助 PDF 提取](../../Scripts/Vocabulary/AI_PROMPT_PDF_TO_CSV.md)

---

## 🎯 开发路线图

### v1.1（近期）
- [ ] 详细学习统计
- [ ] 完整成就系统
- [ ] 学习提醒通知
- [ ] iCloud 数据同步

### v1.2
- [ ] 发音练习功能
- [ ] 拼写练习
- [ ] 自定义学习计划
- [ ] 社交分享功能

### v2.0（长期）
- [ ] 更多语言组合
- [ ] AI 发音评测
- [ ] 用户自定义词汇表
- [ ] 课程模式

---

## 💬 联系方式

- 📧 Email: your.email@example.com
- 💬 GitHub Issues: [提交问题](https://github.com/yourusername/VocFr/issues)
- 📖 文档: [在线文档](https://github.com/yourusername/VocFr/wiki)

---

*欢迎贡献 | 共同进步 | 开源协作*

*最后更新：2025-11-18 | 版本：1.0*
