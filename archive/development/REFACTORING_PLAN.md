# VocFr 项目重构计划

 

**文档版本**: 1.0

**创建日期**: 2025-11-11

**项目**: VocFr - 法语词汇学习 iOS 应用

**当前代码行数**: ~4,089 行

**文件数量**: 19 个 Swift 文件

 

---

 

## 目录

 

1. [项目现状分析](#1-项目现状分析)

2. [重构目标](#2-重构目标)

3. [重构原则](#3-重构原则)

4. [详细重构计划](#4-详细重构计划)

5. [风险评估与应对](#5-风险评估与应对)

6. [验收标准](#6-验收标准)

7. [时间估算](#7-时间估算)

 

---

 

## 1. 项目现状分析

 

### 1.1 项目概况

 

- **应用类型**: iOS 法语词汇学习应用

- **技术栈**: SwiftUI + SwiftData + AVFoundation

- **目标用户**: 法语初学者

- **核心功能**: 词汇学习、音频发音、测试模式、进度跟踪

 

### 1.2 当前架构

 

```

VocFr/

└── VocFr/

    ├── VocFrApp.swift                    (64 行)

    ├── ContentView.swift                 (36 行)

    ├── MainAppView.swift                 (129 行)

    ├── WelcomeView.swift

    ├── Models.swift                      (248 行)

    ├── FrenchWord.swift                  (1,462 行) ⚠️

    ├── WordView.swift                    (571 行) ⚠️

    ├── WordDetailView_Fixed.swift

    ├── WordListView.swift

    ├── WordRowView.swift

    ├── UniteView.swift

    ├── SectionView.swift

    ├── MenuView.swift

    ├── SettingsView.swift

    ├── ProgressView.swift

    ├── PracticeView.swift

    ├── TestModeView.swift

    ├── AudioPlayerManager.swift          (169 行)

    └── SimpleModelTests.swift

```

 

### 1.3 主要问题

 

#### 🔴 严重问题

 

1. **文件组织混乱**

   - 所有文件平铺在一个目录

   - 没有逻辑分组

   - 难以导航和查找

 

2. **数据播种文件过大**

   - `FrenchWord.swift`: 1,462 行

   - 所有词汇数据硬编码

   - 音频时间戳硬编码在代码中

   - 难以维护和更新

 

3. **视图文件臃肿**

   - `WordView.swift`: 571 行

   - 包含 UI、业务逻辑、音频逻辑

   - 缺少关注点分离

 

#### 🟡 中等问题

 

4. **缺少架构模式**

   - 没有明确的 MVVM 或其他架构模式

   - 业务逻辑散布在视图中

   - 难以测试

 

5. **单例模式过度使用**

   - `AudioPlayerManager.shared`

   - 难以进行依赖注入

   - 测试困难

 

#### 🟢 轻微问题

 

6. **命名不一致**

   - `WordDetailView_Fixed.swift` (为什么有 _Fixed?)

   - `FrenchWord.swift` (实际是 Seeder，不是 Word)

 

7. **缺少测试**

   - 只有一个 `SimpleModelTests.swift`

   - 缺少视图测试

   - 缺少业务逻辑测试

 

### 1.4 优势分析

 

✅ **核心功能已实现** (60-70% 完成度)

✅ **数据模型设计合理** (SwiftData 使用得当)

✅ **UI/UX 基础良好** (SwiftUI 视图结构清晰)

✅ **音频功能可用** (支持时间戳精确播放)

✅ **有学习进度跟踪系统**

 

---

 

## 2. 重构目标

 

### 2.1 总体目标

 

**将 VocFr 从一个"能用"的原型转变为一个"可维护、可扩展、可测试"的专业级应用。**

 

### 2.2 具体目标

 

| 目标 | 当前状态 | 目标状态 |

|------|---------|---------|

| 文件组织 | 混乱 (1/10) | 清晰 (9/10) |

| 代码可维护性 | 低 (4/10) | 高 (8/10) |

| 可扩展性 | 中 (5/10) | 高 (9/10) |

| 可测试性 | 低 (2/10) | 高 (8/10) |

| 数据灵活性 | 低 (3/10) | 高 (9/10) |

 

### 2.3 非目标

 

❌ **不重写核心功能**

❌ **不改变用户界面**

❌ **不更换技术栈**

❌ **不做功能性增强** (重构期间专注结构改进)

 

---

 

## 3. 重构原则

 

### 3.1 核心原则

 

1. **渐进式重构**: 小步快跑，每次只改一小部分

2. **保持可运行**: 每个提交后项目都能编译运行

3. **测试先行**: 重构前先写测试（如果没有的话）

4. **代码审查**: 每个重构步骤都要仔细检查

5. **版本控制**: 频繁提交，便于回滚

 

### 3.2 设计原则

 

- **SOLID 原则**

  - Single Responsibility (单一职责)

  - Open/Closed (开放封闭)

  - Liskov Substitution (里氏替换)

  - Interface Segregation (接口隔离)

  - Dependency Inversion (依赖倒置)

 

- **DRY**: Don't Repeat Yourself

- **KISS**: Keep It Simple, Stupid

- **YAGNI**: You Aren't Gonna Need It

 

---

 

## 4. 详细重构计划

 

### 阶段 0: 准备工作 (前置步骤)

 

**时间**: 0.5 天

 

#### 步骤 0.1: 创建重构分支

 

```bash

# 确保主分支干净

git status

git add .

git commit -m "Checkpoint before refactoring"

 

# 创建重构分支

git checkout -b refactor/phase-0-preparation

```

 

#### 步骤 0.2: 备份当前代码

 

```bash

# 创建备份

cd ..

cp -r VocFr VocFr_backup_$(date +%Y%m%d)

```

 

#### 步骤 0.3: 文档化当前功能

 

创建 `CURRENT_FEATURES.md`，记录所有已实现的功能，作为重构后的验收基准。

 

#### 步骤 0.4: 建立基准测试

 

运行应用，测试所有功能，记录：

- 哪些功能可用

- 哪些功能有 bug

- 性能基准（启动时间、内存使用等）

 

---

 

### 阶段 1: 文件组织重构

 

**目标**: 建立清晰的目录结构

**时间**: 1-2 天

**风险**: 低

 

#### 步骤 1.1: 创建新的目录结构

 

```

VocFr/

├── App/

│   └── VocFrApp.swift

├── Models/

│   ├── Domain/

│   │   ├── Unite.swift

│   │   ├── Section.swift

│   │   ├── Word.swift

│   │   ├── WordForm.swift

│   │   ├── SectionWord.swift

│   │   ├── AudioFile.swift

│   │   ├── AudioSegment.swift

│   │   └── Progress/

│   │       ├── UserProgress.swift

│   │       ├── WordProgress.swift

│   │       └── PracticeRecord.swift

│   ├── Enums/

│   │   ├── PartOfSpeech.swift

│   │   ├── WordFormType.swift

│   │   ├── Gender.swift

│   │   └── AudioQuality.swift

│   └── DataSeeding/

│       └── VocabularySeeder.swift

├── Views/

│   ├── Root/

│   │   └── ContentView.swift

│   ├── Welcome/

│   │   └── WelcomeView.swift

│   ├── Main/

│   │   ├── MainAppView.swift

│   │   └── MenuView.swift

│   ├── Learning/

│   │   ├── UniteView.swift

│   │   ├── SectionView.swift

│   │   ├── WordListView.swift

│   │   ├── WordRowView.swift

│   │   └── WordDetail/

│   │       ├── WordDetailView.swift

│   │       └── Components/

│   ├── Test/

│   │   └── TestModeView.swift

│   ├── Practice/

│   │   └── PracticeView.swift

│   ├── Progress/

│   │   └── ProgressView.swift

│   └── Settings/

│       └── SettingsView.swift

├── ViewModels/

│   ├── WordDetailViewModel.swift

│   ├── SectionViewModel.swift

│   └── TestModeViewModel.swift

├── Services/

│   ├── Audio/

│   │   ├── AudioPlayerManager.swift

│   │   └── AudioService.swift

│   ├── Data/

│   │   ├── DataManager.swift

│   │   └── DataLoader.swift

│   └── Progress/

│       └── ProgressTracker.swift

├── Utilities/

│   ├── Extensions/

│   │   ├── String+Extensions.swift

│   │   └── View+Extensions.swift

│   └── Helpers/

│       └── ArticleHelper.swift

├── Resources/

│   ├── Data/

│   │   ├── Unite1.json

│   │   ├── Unite2.json

│   │   ├── Unite3.json

│   │   └── AudioTimestamps.json

│   └── Assets.xcassets/

└── Tests/

    ├── UnitTests/

    │   ├── ModelTests/

    │   ├── ViewModelTests/

    │   └── ServiceTests/

    └── UITests/

        └── VocFrUITests.swift

```

 

#### 步骤 1.2: 移动 App 入口文件

 

```bash

mkdir -p VocFr/App

git mv VocFr/VocFrApp.swift VocFr/App/

```

 

**验证**: 编译并运行，确保应用正常启动

 

**提交**:

```bash

git add .

git commit -m "refactor: Move VocFrApp.swift to App directory"

```

 

#### 步骤 1.3: 拆分并移动 Models

 

##### 1.3.1 拆分 Models.swift

 

当前 `Models.swift` 包含所有模型，需要拆分：

 

```bash

mkdir -p VocFr/Models/Domain

mkdir -p VocFr/Models/Domain/Progress

mkdir -p VocFr/Models/Enums

```

 

创建文件：

- `VocFr/Models/Enums/PartOfSpeech.swift`

- `VocFr/Models/Enums/WordFormType.swift`

- `VocFr/Models/Enums/Gender.swift`

- `VocFr/Models/Enums/Number.swift`

- `VocFr/Models/Enums/AudioQuality.swift`

- `VocFr/Models/Domain/Unite.swift`

- `VocFr/Models/Domain/Section.swift`

- `VocFr/Models/Domain/Word.swift`

- `VocFr/Models/Domain/WordForm.swift`

- `VocFr/Models/Domain/SectionWord.swift`

- `VocFr/Models/Domain/AudioFile.swift`

- `VocFr/Models/Domain/AudioSegment.swift`

- `VocFr/Models/Domain/Progress/UserProgress.swift`

- `VocFr/Models/Domain/Progress/WordProgress.swift`

- `VocFr/Models/Domain/Progress/PracticeRecord.swift`

 

**每个文件一个模型**，包含清晰的文档注释。

 

**验证**: 编译通过

 

**提交**:

```bash

git add .

git commit -m "refactor: Split Models.swift into separate files"

```

 

##### 1.3.2 移动和重命名数据播种文件

 

```bash

mkdir -p VocFr/Models/DataSeeding

git mv VocFr/FrenchWord.swift VocFr/Models/DataSeeding/VocabularySeeder.swift

```

 

**更新文件内容**: 重命名类和添加文档

 

**验证**: 编译通过

 

**提交**:

```bash

git add .

git commit -m "refactor: Move and rename FrenchWord.swift to VocabularySeeder.swift"

```

 

#### 步骤 1.4: 组织 Views

 

```bash

mkdir -p VocFr/Views/Root

mkdir -p VocFr/Views/Welcome

mkdir -p VocFr/Views/Main

mkdir -p VocFr/Views/Learning/WordDetail/Components

mkdir -p VocFr/Views/Test

mkdir -p VocFr/Views/Practice

mkdir -p VocFr/Views/Progress

mkdir -p VocFr/Views/Settings

 

# 移动文件

git mv VocFr/ContentView.swift VocFr/Views/Root/

git mv VocFr/WelcomeView.swift VocFr/Views/Welcome/

git mv VocFr/MainAppView.swift VocFr/Views/Main/

git mv VocFr/MenuView.swift VocFr/Views/Main/

git mv VocFr/UniteView.swift VocFr/Views/Learning/

git mv VocFr/SectionView.swift VocFr/Views/Learning/

git mv VocFr/WordListView.swift VocFr/Views/Learning/

git mv VocFr/WordRowView.swift VocFr/Views/Learning/

git mv VocFr/WordView.swift VocFr/Views/Learning/WordDetail/WordDetailView.swift

git mv VocFr/TestModeView.swift VocFr/Views/Test/

git mv VocFr/PracticeView.swift VocFr/Views/Practice/

git mv VocFr/ProgressView.swift VocFr/Views/Progress/

git mv VocFr/SettingsView.swift VocFr/Views/Settings/

```

 

**处理 WordDetailView_Fixed.swift**:

- 检查与 WordView.swift 的区别

- 合并到 WordDetailView.swift

- 删除 _Fixed 文件

 

**验证**: 编译并运行，测试所有视图

 

**提交**:

```bash

git add .

git commit -m "refactor: Organize views into logical directories"

```

 

#### 步骤 1.5: 组织 Services

 

```bash

mkdir -p VocFr/Services/Audio

 

git mv VocFr/AudioPlayerManager.swift VocFr/Services/Audio/

```

 

**验证**: 编译通过

 

**提交**:

```bash

git add .

git commit -m "refactor: Move services to Services directory"

```

 

#### 步骤 1.6: 更新 Xcode 项目文件

 

在 Xcode 中：

1. 删除旧的文件引用

2. 添加新的目录和文件引用

3. 确保所有文件都包含在编译目标中

 

**验证**:

- 在 Xcode 中编译

- 运行应用

- 测试所有核心功能

 

**提交**:

```bash

git add .

git commit -m "refactor: Update Xcode project structure"

```

 

#### 步骤 1.7: 阶段 1 验收

 

**检查清单**:

- [ ] 所有文件都在正确的目录

- [ ] 没有重复或孤儿文件

- [ ] 应用可以编译

- [ ] 所有功能正常运行

- [ ] Git 历史清晰

 

**完成后推送**:

```bash

git push origin refactor/phase-1-file-organization

```

 

---

 

### 阶段 2: 数据层重构

 

**目标**: 将硬编码数据提取到 JSON 文件

**时间**: 2-3 天

**风险**: 中

 

#### 步骤 2.1: 创建 JSON 数据结构

 

##### 2.1.1 设计 JSON Schema

 

创建 `VocFr/Resources/Data/schema.md` 文档 JSON 格式：

 

```json

{

  "unites": [

    {

      "id": "unite1",

      "number": 1,

      "title": "À l'école",

      "isUnlocked": true,

      "requiredStars": 0,

      "sections": [

        {

          "id": "section1_1",

          "name": "à l'école",

          "orderIndex": 1,

          "words": [

            {

              "id": "bureau",

              "canonical": "bureau",

              "chinese": "课桌",

              "imageName": "bureau_image",

              "partOfSpeech": "noun",

              "category": "school_objects",

              "gender": "masculine",

              "elision": false,

              "forms": [

                {

                  "formType": "indefiniteArticle",

                  "french": "un bureau",

                  "isMainForm": true

                },

                {

                  "formType": "definiteArticle",

                  "french": "le bureau",

                  "isMainForm": false

                }

              ]

            }

          ]

        }

      ]

    }

  ]

}

```

 

##### 2.1.2 创建 JSON 数据文件

 

```bash

mkdir -p VocFr/Resources/Data

```

 

创建文件：

- `Unite1.json`

- `Unite2.json`

- `Unite3.json`

- `AudioTimestamps.json`

 

##### 2.1.3 提取 Unite 1 数据

 

从 `VocabularySeeder.swift` 中提取 Unite 1 的所有数据到 `Unite1.json`。

 

**工具脚本** (可选):

创建 Python/Swift 脚本自动提取数据，减少手工错误。

 

**验证**:

- JSON 格式正确

- 数据完整

- 使用在线 JSON 验证器

 

**提交**:

```bash

git add VocFr/Resources/Data/Unite1.json

git commit -m "refactor: Extract Unite 1 data to JSON"

```

 

##### 2.1.4 提取 Unite 2 和 Unite 3 数据

 

重复上述过程。

 

**提交**:

```bash

git add VocFr/Resources/Data/Unite2.json

git add VocFr/Resources/Data/Unite3.json

git commit -m "refactor: Extract Unite 2 and 3 data to JSON"

```

 

##### 2.1.5 提取音频时间戳

 

创建 `AudioTimestamps.json`:

 

```json

{

  "audioFile": {

    "fileName": "alloy_gpt-4o-mini-tts_0-75x_2025-09-23T22_28_54-859Z.wav",

    "duration": 120.0

  },

  "timestamps": [

    {

      "wordId": "bureau",

      "formType": "indefiniteArticle",

      "startTime": 0.0,

      "endTime": 1.2

    }

  ]

}

```

 

**提交**:

```bash

git add VocFr/Resources/Data/AudioTimestamps.json

git commit -m "refactor: Extract audio timestamps to JSON"

```

 

#### 步骤 2.2: 创建数据加载器

 

##### 2.2.1 创建 DataLoader 服务

 

创建 `VocFr/Services/Data/DataLoader.swift`:

 

```swift

import Foundation

 

struct DataLoader {

    static func loadUnite(number: Int) throws -> UniteDTO {

        guard let url = Bundle.main.url(

            forResource: "Unite\(number)",

            withExtension: "json",

            subdirectory: "Data"

        ) else {

            throw DataLoaderError.fileNotFound("Unite\(number).json")

        }

 

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()

        return try decoder.decode(UniteDTO.self, from: data)

    }

 

    static func loadAudioTimestamps() throws -> AudioTimestampsDTO {

        guard let url = Bundle.main.url(

            forResource: "AudioTimestamps",

            withExtension: "json",

            subdirectory: "Data"

        ) else {

            throw DataLoaderError.fileNotFound("AudioTimestamps.json")

        }

 

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()

        return try decoder.decode(AudioTimestampsDTO.self, from: data)

    }

}

 

enum DataLoaderError: Error {

    case fileNotFound(String)

    case decodingError(Error)

}

```

 

##### 2.2.2 创建 DTO (Data Transfer Objects)

 

创建 `VocFr/Models/DTO/` 目录和相应的 DTO 结构：

 

- `UniteDTO.swift`

- `SectionDTO.swift`

- `WordDTO.swift`

- `AudioTimestampsDTO.swift`

 

##### 2.2.3 重构 VocabularySeeder

 

更新 `VocabularySeeder.swift` 使用 `DataLoader`:

 

```swift

class VocabularySeeder {

    static func seedAllData(to modelContext: ModelContext) throws {

        // 从 JSON 加载数据

        let unite1DTO = try DataLoader.loadUnite(number: 1)

        let unite2DTO = try DataLoader.loadUnite(number: 2)

        let unite3DTO = try DataLoader.loadUnite(number: 3)

 

        // 转换 DTO 到 SwiftData 模型

        let unite1 = createUnite(from: unite1DTO)

        let unite2 = createUnite(from: unite2DTO)

        let unite3 = createUnite(from: unite3DTO)

 

        // 插入数据

        modelContext.insert(unite1)

        modelContext.insert(unite2)

        modelContext.insert(unite3)

 

        try modelContext.save()

    }

 

    private static func createUnite(from dto: UniteDTO) -> Unite {

        // 转换逻辑

    }

}

```

 

**验证**:

- 编译通过

- 应用启动时正确加载数据

- 所有单词都显示正确

 

**提交**:

```bash

git add .

git commit -m "refactor: Implement JSON data loading"

```

 

#### 步骤 2.3: 清理旧代码

 

删除 `VocabularySeeder.swift` 中所有硬编码的数据：

- `createUnite1()`, `createUnite2()`, `createUnite3()`

- `createSection1_1()` 等所有方法

- `parseAudioTimestamps()` 中的硬编码数组

 

保留：

- 数据加载逻辑

- 数据验证方法

- 辅助方法

 

**验证**:

- 代码量显著减少

- 功能完全一致

 

**提交**:

```bash

git add .

git commit -m "refactor: Remove hardcoded data from VocabularySeeder"

```

 

#### 步骤 2.4: 阶段 2 验收

 

**检查清单**:

- [ ] 所有数据在 JSON 文件中

- [ ] DataLoader 正确加载数据

- [ ] 应用启动正常

- [ ] 所有单词、图片、音频都正常

- [ ] VocabularySeeder.swift 代码行数减少 > 80%

 

**性能测试**:

- 启动时间没有显著增加

- 内存使用没有显著增加

 

**完成后推送**:

```bash

git push origin refactor/phase-2-data-layer

```

 

---

 

### 阶段 3: 视图层重构 (MVVM)

 

**目标**: 引入 MVVM 架构，分离业务逻辑

**时间**: 3-5 天

**风险**: 中-高

 

#### 步骤 3.1: 创建 ViewModel 基础设施

 

##### 3.1.1 创建 ViewModel 协议

 

创建 `VocFr/ViewModels/ViewModelProtocol.swift`:

 

```swift

import Foundation

import Combine

 

protocol ViewModelProtocol: ObservableObject {

    associatedtype State

    associatedtype Action

 

    var state: State { get }

    func send(_ action: Action)

}

```

 

##### 3.1.2 创建第一个 ViewModel: WordDetailViewModel

 

创建 `VocFr/ViewModels/WordDetailViewModel.swift`:

 

```swift

import Foundation

import SwiftUI

import Combine

 

@MainActor

class WordDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var currentWordIndex: Int

    @Published var showWordCard: Bool = true

    @Published var isShuffled: Bool = false

 

    // MARK: - Private Properties

    private let section: Section

    private var originalWords: [SectionWord] = []

    private var shuffledWords: [SectionWord] = []

    private let audioService: AudioServiceProtocol

 

    // MARK: - Computed Properties

    var currentWord: Word? {

        let words = isShuffled ? shuffledWords : originalWords

        guard currentWordIndex >= 0 && currentWordIndex < words.count else {

            return nil

        }

        return words[currentWordIndex].word

    }

 

    var canGoToPrevious: Bool {

        currentWordIndex > 0

    }

 

    var canGoToNext: Bool {

        let words = isShuffled ? shuffledWords : originalWords

        return currentWordIndex < words.count - 1

    }

 

    // MARK: - Initialization

    init(

        section: Section,

        currentWordIndex: Int,

        audioService: AudioServiceProtocol = AudioService.shared

    ) {

        self.section = section

        self.currentWordIndex = currentWordIndex

        self.audioService = audioService

        self.originalWords = section.sectionWords.sorted { $0.orderIndex < $1.orderIndex }

        self.shuffledWords = originalWords.shuffled()

    }

 

    // MARK: - Actions

    func goToPrevious() {

        guard canGoToPrevious else { return }

        currentWordIndex -= 1

        hapticFeedback(.light)

    }

 

    func goToNext() {

        guard canGoToNext else { return }

        currentWordIndex += 1

        hapticFeedback(.light)

    }

 

    func toggleShuffle() {

        isShuffled.toggle()

        // Maintain current word position logic

        hapticFeedback(.medium)

    }

 

    func toggleWordCard() {

        showWordCard.toggle()

    }

 

    func playAudio() {

        guard let word = currentWord else { return }

        audioService.playWord(word)

    }

 

    // MARK: - Helper Methods

    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {

        let generator = UIImpactFeedbackGenerator(style: style)

        generator.impactOccurred()

    }

}

```

 

**提交**:

```bash

git add VocFr/ViewModels/WordDetailViewModel.swift

git commit -m "refactor: Create WordDetailViewModel"

```

 

#### 步骤 3.2: 创建 AudioService

 

##### 3.2.1 定义协议

 

创建 `VocFr/Services/Audio/AudioServiceProtocol.swift`:

 

```swift

import Foundation

import Combine

 

protocol AudioServiceProtocol {

    var isPlaying: Bool { get }

    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }

 

    func playWord(_ word: Word)

    func stop()

}

```

 

##### 3.2.2 实现 AudioService

 

创建 `VocFr/Services/Audio/AudioService.swift`:

 

```swift

import Foundation

import AVFoundation

import Combine

 

class AudioService: NSObject, AudioServiceProtocol, ObservableObject {

    static let shared = AudioService()

 

    @Published private(set) var isPlaying: Bool = false

 

    var isPlayingPublisher: AnyPublisher<Bool, Never> {

        $isPlaying.eraseToAnyPublisher()

    }

 

    private let audioManager: AudioPlayerManager

 

    init(audioManager: AudioPlayerManager = .shared) {

        self.audioManager = audioManager

        super.init()

    }

 

    func playWord(_ word: Word) {

        // Implementation using AudioPlayerManager

        if let segment = word.audioSegments.first,

           let file = segment.audioFile {

            audioManager.togglePlayback(

                filename: file.fileName,

                startTime: segment.startTime,

                endTime: segment.endTime

            ) { [weak self] success in

                self?.isPlaying = success

            }

        }

    }

 

    func stop() {

        audioManager.stopAudio()

        isPlaying = false

    }

}

```

 

**提交**:

```bash

git add .

git commit -m "refactor: Create AudioService abstraction"

```

 

#### 步骤 3.3: 重构 WordDetailView 使用 ViewModel

 

更新 `WordDetailView.swift`:

 

```swift

struct WordDetailView: View {

    @StateObject private var viewModel: WordDetailViewModel

    @Environment(\.dismiss) private var dismiss

 

    init(section: Section, currentWordIndex: Int) {

        _viewModel = StateObject(wrappedValue: WordDetailViewModel(

            section: section,

            currentWordIndex: currentWordIndex

        ))

    }

 

    var body: some View {

        // Use viewModel properties instead of @State

        // viewModel.currentWord

        // viewModel.showWordCard

        // viewModel.goToNext()

        // viewModel.playAudio()

    }

}

```

 

**步骤**:

1. 用 ViewModel 替换所有 @State 属性

2. 用 ViewModel 方法替换所有业务逻辑

3. 保持 UI 代码不变

 

**验证**:

- 编译通过

- 功能完全一致

- UI 流畅度不变

 

**提交**:

```bash

git add .

git commit -m "refactor: Refactor WordDetailView to use ViewModel"

```

 

#### 步骤 3.4: 拆分大型视图

 

##### 3.4.1 拆分 WordDetailView 组件

 

当前 `WordDetailView.swift` 571 行，拆分为：

 

1. **WordDetailView.swift** (~150 行)

   - 主视图结构

   - 导航和手势

 

2. **WordCardView.swift** (~100 行)

   - 单词卡片显示

   - 词形变化展示

 

3. **WordImageView.swift** (~50 行)

   - 图片显示

   - 占位符

 

4. **ArticleBlockView.swift** (~80 行)

   - 冠词展示

   - 语法信息

 

5. **WordDetailToolbar.swift** (~50 行)

   - 工具栏按钮

   - 状态指示器

 

**创建目录**:

```bash

mkdir -p VocFr/Views/Learning/WordDetail/Components

```

 

**提取组件**:

 

创建 `ArticleBlockView.swift`:

```swift

struct ArticleBlockView: View {

    let word: Word

 

    var body: some View {

        // Extract article block logic from WordDetailView

    }

}

```

 

依此类推创建其他组件。

 

**更新 WordDetailView**:

```swift

struct WordDetailView: View {

    @StateObject private var viewModel: WordDetailViewModel

 

    var body: some View {

        VStack {

            WordImageView(word: viewModel.currentWord)

 

            if viewModel.showWordCard {

                WordCardView(

                    word: viewModel.currentWord,

                    onPlayAudio: viewModel.playAudio

                )

            }

        }

        .toolbar {

            WordDetailToolbar(

                showWordCard: $viewModel.showWordCard,

                isShuffled: $viewModel.isShuffled,

                onToggleShuffle: viewModel.toggleShuffle

            )

        }

    }

}

```

 

**验证**:

- 每个文件 < 200 行

- 编译通过

- 功能一致

 

**提交**:

```bash

git add .

git commit -m "refactor: Split WordDetailView into components"

```

 

#### 步骤 3.5: 重复其他视图

 

对以下视图应用相同的模式：

- SectionView → SectionViewModel

- TestModeView → TestModeViewModel

- (其他需要的视图)

 

#### 步骤 3.6: 阶段 3 验收

 

**检查清单**:

- [ ] 所有复杂视图都有 ViewModel

- [ ] 业务逻辑都在 ViewModel 中

- [ ] 视图只包含 UI 代码

- [ ] 单个文件 < 300 行

- [ ] 所有功能正常

 

**代码质量**:

- [ ] 符合 MVVM 模式

- [ ] 依赖注入就位

- [ ] 可测试性提高

 

**完成后推送**:

```bash

git push origin refactor/phase-3-mvvm

```

 

---

 

### 阶段 4: 依赖注入和测试

 

**目标**: 建立可测试的架构

**时间**: 2-3 天

**风险**: 低

 

#### 步骤 4.1: 实现依赖注入容器

 

##### 4.1.1 创建环境值

 

创建 `VocFr/Services/DependencyInjection/EnvironmentValues.swift`:

 

```swift

import SwiftUI

 

// MARK: - Audio Service

private struct AudioServiceKey: EnvironmentKey {

    static let defaultValue: AudioServiceProtocol = AudioService.shared

}

 

extension EnvironmentValues {

    var audioService: AudioServiceProtocol {

        get { self[AudioServiceKey.self] }

        set { self[AudioServiceKey.self] = newValue }

    }

}

 

// MARK: - Data Manager

private struct DataManagerKey: EnvironmentKey {

    static let defaultValue: DataManagerProtocol = DataManager.shared

}

 

extension EnvironmentValues {

    var dataManager: DataManagerProtocol {

        get { self[DataManagerKey.self] }

        set { self[DataManagerKey.self] = newValue }

    }

}

```

 

##### 4.1.2 更新 ViewModels 使用注入

 

```swift

class WordDetailViewModel: ObservableObject {

    private let audioService: AudioServiceProtocol

 

    init(

        section: Section,

        currentWordIndex: Int,

        audioService: AudioServiceProtocol  // Injected

    ) {

        self.section = section

        self.currentWordIndex = currentWordIndex

        self.audioService = audioService

    }

}

```

 

##### 4.1.3 在 App 中配置

 

```swift

@main

struct VocFrApp: App {

    var body: some Scene {

        WindowGroup {

            ContentView()

                .environment(\.audioService, AudioService.shared)

                .environment(\.dataManager, DataManager.shared)

                .modelContainer(createModelContainer())

        }

    }

}

```

 

**提交**:

```bash

git add .

git commit -m "refactor: Implement dependency injection"

```

 

#### 步骤 4.2: 编写单元测试

 

##### 4.2.1 创建 Mock 对象

 

创建 `VocFrTests/Mocks/MockAudioService.swift`:

 

```swift

import Foundation

import Combine

@testable import VocFr

 

class MockAudioService: AudioServiceProtocol {

    var isPlaying: Bool = false

    var isPlayingPublisher: AnyPublisher<Bool, Never> {

        Just(isPlaying).eraseToAnyPublisher()

    }

 

    private(set) var playWordCalled = false

    private(set) var lastPlayedWord: Word?

 

    func playWord(_ word: Word) {

        playWordCalled = true

        lastPlayedWord = word

        isPlaying = true

    }

 

    func stop() {

        isPlaying = false

    }

}

```

 

##### 4.2.2 测试 ViewModels

 

创建 `VocFrTests/ViewModelTests/WordDetailViewModelTests.swift`:

 

```swift

import XCTest

@testable import VocFr

 

@MainActor

class WordDetailViewModelTests: XCTestCase {

    var sut: WordDetailViewModel!

    var mockAudioService: MockAudioService!

    var testSection: Section!

 

    override func setUp() {

        super.setUp()

        mockAudioService = MockAudioService()

        testSection = createTestSection()

        sut = WordDetailViewModel(

            section: testSection,

            currentWordIndex: 0,

            audioService: mockAudioService

        )

    }

 

    override func tearDown() {

        sut = nil

        mockAudioService = nil

        testSection = nil

        super.tearDown()

    }

 

    func testInitialState() {

        XCTAssertEqual(sut.currentWordIndex, 0)

        XCTAssertTrue(sut.showWordCard)

        XCTAssertFalse(sut.isShuffled)

    }

 

    func testGoToNext() {

        sut.goToNext()

        XCTAssertEqual(sut.currentWordIndex, 1)

    }

 

    func testCannotGoNextAtEnd() {

        sut.currentWordIndex = testSection.sectionWords.count - 1

        XCTAssertFalse(sut.canGoToNext)

    }

 

    func testPlayAudio() {

        sut.playAudio()

        XCTAssertTrue(mockAudioService.playWordCalled)

        XCTAssertNotNil(mockAudioService.lastPlayedWord)

    }

 

    func testToggleShuffle() {

        XCTAssertFalse(sut.isShuffled)

        sut.toggleShuffle()

        XCTAssertTrue(sut.isShuffled)

    }

 

    // MARK: - Helpers

    private func createTestSection() -> Section {

        // Create test data

    }

}

```

 

##### 4.2.3 测试 Services

 

创建 `VocFrTests/ServiceTests/AudioServiceTests.swift`

创建 `VocFrTests/ServiceTests/DataLoaderTests.swift`

 

##### 4.2.4 测试 Models

 

创建 `VocFrTests/ModelTests/WordTests.swift`

 

**目标**: 测试覆盖率 > 70%

 

**运行测试**:

```bash

# 在 Xcode 中: Cmd + U

# 或命令行

xcodebuild test -scheme VocFr -destination 'platform=iOS Simulator,name=iPhone 15'

```

 

**提交**:

```bash

git add .

git commit -m "test: Add unit tests for ViewModels and Services"

```

 

#### 步骤 4.3: UI 测试

 

创建基本的 UI 测试覆盖主要流程：

 

```swift

class VocFrUITests: XCTestCase {

    var app: XCUIApplication!

 

    override func setUp() {

        super.setUp()

        continueAfterFailure = false

        app = XCUIApplication()

        app.launch()

    }

 

    func testCompleteWordLearningFlow() {

        // Test welcome screen

        XCTAssertTrue(app.buttons["开始学习"].exists)

        app.buttons["开始学习"].tap()

 

        // Test main menu

        XCTAssertTrue(app.buttons["学习"].exists)

        app.buttons["学习"].tap()

 

        // Test unite selection

        // Test section selection

        // Test word detail view

        // Test swipe navigation

        // Test audio playback

    }

}

```

 

**提交**:

```bash

git add .

git commit -m "test: Add UI tests for main flows"

```

 

#### 步骤 4.4: 阶段 4 验收

 

**检查清单**:

- [ ] 依赖注入实现

- [ ] 单元测试覆盖率 > 70%

- [ ] UI 测试覆盖主要流程

- [ ] 所有测试通过

- [ ] CI/CD 集成 (可选)

 

**完成后推送**:

```bash

git push origin refactor/phase-4-di-and-tests

```

 

---

 

### 阶段 5: 优化和文档

 

**目标**: 完善细节，编写文档

**时间**: 1-2 天

**风险**: 低

 

#### 步骤 5.1: 代码优化

 

##### 5.1.1 提取辅助函数

 

创建 `VocFr/Utilities/Helpers/ArticleHelper.swift`:

 

```swift

import Foundation

 

struct ArticleHelper {

    static func beginsWithVowelOrH(_ word: String) -> Bool {

        let lower = word.lowercased()

        let vowels = ["a","e","i","o","u","y","à","â","ä","é","è","ê","ë","î","ï","ô","ö","ù","û","ü","h"]

        return vowels.contains { lower.hasPrefix($0) }

    }

 

    static func definiteSingular(for base: String, gender: Gender) -> String {

        if beginsWithVowelOrH(base) { return "l'\(base)" }

        return (gender == .masculine ? "le " : "la ") + base

    }

 

    static func indefiniteSingular(for base: String, gender: Gender) -> String {

        return (gender == .masculine ? "un " : "une ") + base

    }

 

    static func pluralized(_ base: String) -> String {

        return base + "s"

    }

}

```

 

##### 5.1.2 创建扩展

 

创建 `VocFr/Utilities/Extensions/String+Extensions.swift`:

 

```swift

import Foundation

 

extension String {

    func removingArticle() -> String {

        let articles = ["le ", "la ", "les ", "un ", "une ", "des ", "l'"]

        let lowercased = self.lowercased()

 

        for article in articles {

            if lowercased.hasPrefix(article) {

                return String(self.dropFirst(article.count))

            }

        }

        return self

    }

 

    var normalized: String {

        return self

            .replacingOccurrences(of: "é", with: "e")

            .replacingOccurrences(of: "è", with: "e")

            .replacingOccurrences(of: "ê", with: "e")

            // ... more replacements

            .lowercased()

    }

}

```

 

创建 `VocFr/Utilities/Extensions/View+Extensions.swift`:

 

```swift

import SwiftUI

 

extension View {

    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {

        self.onTapGesture {

            let generator = UIImpactFeedbackGenerator(style: style)

            generator.impactOccurred()

        }

    }

}

```

 

**提交**:

```bash

git add .

git commit -m "refactor: Extract utilities and extensions"

```

 

#### 步骤 5.2: 代码文档

 

##### 5.2.1 添加代码注释

 

为所有公共接口添加文档注释：

 

```swift

/// 管理单词详情视图的状态和业务逻辑

///

/// `WordDetailViewModel` 负责：

/// - 管理当前显示的单词

/// - 处理单词导航（上一个/下一个）

/// - 控制单词卡片的显示/隐藏

/// - 管理随机播放模式

/// - 协调音频播放

///

/// - Note: 使用 `@MainActor` 确保所有 UI 更新在主线程

class WordDetailViewModel: ObservableObject {

    /// 当前显示单词的索引

    @Published var currentWordIndex: Int

 

    /// 是否显示单词卡片

    @Published var showWordCard: Bool = true

 

    // ...

}

```

 

##### 5.2.2 创建架构文档

 

创建 `ARCHITECTURE.md`:

 

```markdown

# VocFr 架构文档

 

## 概述

 

VocFr 采用 MVVM (Model-View-ViewModel) 架构模式...

 

## 目录结构

 

...

 

## 数据流

 

...

 

## 关键组件

 

...

```

 

##### 5.2.3 更新 README

 

更新 `README.md` 包含：

- 项目描述

- 功能特性

- 技术栈

- 安装指南

- 构建指南

- 贡献指南

- 许可证

 

**提交**:

```bash

git add .

git commit -m "docs: Add comprehensive documentation"

```

 

#### 步骤 5.3: 性能优化

 

##### 5.3.1 图片加载优化

 

如果有大量图片，考虑：

- 图片懒加载

- 图片缓存

- 压缩策略

 

##### 5.3.2 数据加载优化

 

- 延迟加载未解锁的单元

- 后台加载音频数据

 

##### 5.3.3 测试性能

 

使用 Instruments 检查：

- 内存泄漏

- CPU 使用

- 启动时间

 

**提交性能改进**:

```bash

git add .

git commit -m "perf: Optimize image and data loading"

```

 

#### 步骤 5.4: 最终清理

 

##### 5.4.1 移除未使用代码

 

- 删除未使用的导入

- 删除注释掉的代码

- 删除 TODO 标记（或创建 GitHub Issues）

 

##### 5.4.2 格式化代码

 

使用 SwiftLint 或 SwiftFormat 统一代码风格。

 

##### 5.4.3 更新 .gitignore

 

确保不提交：

- 构建产物

- 用户特定文件

- 敏感信息

 

**提交**:

```bash

git add .

git commit -m "chore: Final cleanup and formatting"

```

 

#### 步骤 5.5: 阶段 5 验收

 

**检查清单**:

- [ ] 代码有完整注释

- [ ] 文档完善

- [ ] 无未使用代码

- [ ] 代码格式统一

- [ ] 性能优化完成

 

**完成后推送**:

```bash

git push origin refactor/phase-5-optimization

```

 

---

 

## 5. 风险评估与应对

 

### 5.1 风险矩阵

 

| 风险 | 概率 | 影响 | 级别 | 应对措施 |

|------|------|------|------|---------|

| 功能破坏 | 中 | 高 | 高 | 充分测试，频繁提交 |

| 数据丢失 | 低 | 高 | 中 | 备份，版本控制 |

| 时间超支 | 中 | 中 | 中 | 分阶段，可回退 |

| Merge 冲突 | 低 | 低 | 低 | 单人开发，影响小 |

| 性能下降 | 低 | 中 | 低 | 性能测试，及时优化 |

 

### 5.2 回滚策略

 

**如果某个阶段出现严重问题**:

 

```bash

# 回退到阶段开始

git reset --hard <phase-start-commit>

 

# 或创建新分支从头开始该阶段

git checkout -b refactor/phase-X-retry <phase-start-commit>

```

 

**保留备份**:

- 每个阶段开始前创建备份

- 每天结束时创建备份

- 重要节点创建 Git 标签

 

```bash

git tag -a phase-1-complete -m "Phase 1 refactoring complete"

```

 

### 5.3 应急预案

 

**如果发现新的严重 Bug**:

1. 停止重构

2. 在当前状态创建 Bug 修复分支

3. 修复后合并回重构分支

4. 继续重构

 

---

 

## 6. 验收标准

 

### 6.1 功能验收

 

**所有现有功能必须完整保留**:

- [ ] 欢迎界面

- [ ] 主菜单导航

- [ ] 单元列表

- [ ] Section 列表

- [ ] 单词列表

- [ ] 单词详情（图片、法语、中文、音频）

- [ ] 滑动翻页

- [ ] 随机播放

- [ ] 音频播放

- [ ] 测试模式

- [ ] 进度追踪

 

### 6.2 代码质量验收

 

| 指标 | 当前 | 目标 | 验收标准 |

|------|------|------|---------|

| 最大文件行数 | 1,462 | < 300 | 通过 |

| 平均文件行数 | ~215 | < 150 | 通过 |

| 目录层级 | 1 | 3-4 | 清晰的层级结构 |

| 测试覆盖率 | ~0% | > 70% | 关键逻辑覆盖 |

| 循环复杂度 | - | < 10 | 每个函数 |

| 代码重复率 | - | < 5% | 无大段重复 |

 

### 6.3 架构验收

 

- [ ] 符合 MVVM 模式

- [ ] 清晰的层次分离

- [ ] 依赖注入实现

- [ ] 数据与代码分离

- [ ] 可扩展性良好

 

### 6.4 性能验收

 

| 指标 | 当前基准 | 目标 | 验收标准 |

|------|---------|------|---------|

| 应用启动时间 | 记录基准 | < 基准 × 1.2 | 不显著增加 |

| 内存占用 | 记录基准 | < 基准 × 1.1 | 不显著增加 |

| 视图切换时间 | 记录基准 | < 基准 × 1.1 | 保持流畅 |

| 音频播放延迟 | 记录基准 | < 基准 | 无回归 |

 

### 6.5 文档验收

 

- [ ] README.md 完整

- [ ] ARCHITECTURE.md 清晰

- [ ] 代码注释充分

- [ ] API 文档完整

- [ ] 重构文档完整

 

---

 

## 7. 时间估算

 

### 7.1 总体时间线

 

| 阶段 | 工作量（天） | 缓冲（天） | 总计（天） |

|------|------------|-----------|-----------|

| 阶段 0: 准备 | 0.5 | 0 | 0.5 |

| 阶段 1: 文件组织 | 1-2 | 0.5 | 2.5 |

| 阶段 2: 数据层 | 2-3 | 1 | 4 |

| 阶段 3: MVVM | 3-5 | 1.5 | 6.5 |

| 阶段 4: DI & 测试 | 2-3 | 1 | 4 |

| 阶段 5: 优化文档 | 1-2 | 0.5 | 2.5 |

| **总计** | **9.5-15.5** | **4.5** | **20** |

 

### 7.2 建议时间表

 

**如果每天投入 2-3 小时**:

- 总共需要: 约 2-3 周

- 建议节奏: 一周完成 1-2 个阶段

 

**如果每天投入 4-6 小时**:

- 总共需要: 约 1-2 周

- 建议节奏: 一周完成 2-3 个阶段

 

**如果全职投入（8 小时/天）**:

- 总共需要: 约 1 周

- 建议节奏: 每天完成 1 个阶段

 

### 7.3 里程碑

 

- **Day 3**: 阶段 1 完成 - 文件组织清晰

- **Day 7**: 阶段 2 完成 - 数据与代码分离

- **Day 13**: 阶段 3 完成 - MVVM 架构建立

- **Day 17**: 阶段 4 完成 - 测试覆盖完成

- **Day 20**: 阶段 5 完成 - 重构全部完成

 

---

 

## 8. 后续规划

 

### 8.1 重构完成后

 

**立即进行**:

1. 完整的回归测试

2. 性能对比测试

3. 代码审查

4. 文档最终检查

 

**短期内 (1-2 周)**:

1. 监控用户反馈（如果有测试用户）

2. 修复遗留问题

3. 持续集成/持续部署设置

 

### 8.2 新功能开发准备

 

重构完成后，架构已经就位，可以：

- 更容易添加新功能

- 更容易修复 Bug

- 更容易进行团队协作

 

**建议的新功能顺序**:

1. 完善测试模式

2. 添加游戏模式

3. 添加社交功能

4. 添加离线支持

 

### 8.3 持续改进

 

**建立开发流程**:

- 定期代码审查

- 持续测试

- 性能监控

- 用户反馈收集

 

---

 

## 9. 附录

 

### 9.1 有用的命令

 

```bash

# 查看项目代码统计

find VocFr -name "*.swift" | xargs wc -l | sort -n

 

# 查看最大的文件

find VocFr -name "*.swift" -exec wc -l {} \; | sort -rn | head

 

# 运行测试

xcodebuild test -scheme VocFr -destination 'platform=iOS Simulator,name=iPhone 15'

 

# 生成代码覆盖率报告

# 在 Xcode: Scheme → Edit Scheme → Test → Options → Code Coverage

```

 

### 9.2 推荐工具

 

**代码质量**:

- SwiftLint: 代码规范检查

- SwiftFormat: 代码格式化

- Periphery: 未使用代码检测

 

**性能分析**:

- Instruments: Xcode 自带性能分析工具

- Memory Graph Debugger: 内存泄漏检测

 

**文档生成**:

- DocC: Swift 官方文档工具

- Jazzy: API 文档生成

 

### 9.3 学习资源

 

**MVVM 架构**:

- SwiftUI MVVM Architecture (Paul Hudson)

- Clean Architecture in iOS (Uncle Bob)

 

**测试**:

- Test-Driven Development in Swift

- UI Testing Best Practices

 

**SwiftUI 最佳实践**:

- SwiftUI by Example (Paul Hudson)

- Thinking in SwiftUI

 

---

 

## 10. 总结

 

这份重构计划提供了一个**系统化、分阶段、低风险**的方式来改善 VocFr 项目的架构和代码质量。

 

**关键成功因素**:

1. ✅ **小步快跑**: 每次只改一小部分

2. ✅ **频繁测试**: 确保每步都不破坏功能

3. ✅ **版本控制**: 随时可以回滚

4. ✅ **耐心执行**: 不急于求成

5. ✅ **持续改进**: 重构是持续的过程

 

**预期收益**:

- 📊 代码可维护性提升 100%+

- 🚀 新功能开发速度提升 50%+

- 🐛 Bug 修复时间减少 60%+

- 🧪 测试覆盖率从 0% 到 70%+

- 👥 团队协作效率提升 80%+

 

**祝重构顺利！** 🎉

 

---

 

**版本历史**:

- v1.0 (2025-11-11): 初始版本
