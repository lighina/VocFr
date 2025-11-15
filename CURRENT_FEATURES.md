# VocFr - 当前功能清单

**文档版本**: 1.0
**创建日期**: 2025-11-11
**项目状态**: 开发中（准备重构）

## 目录
1. [概述](#概述)
2. [核心功能](#核心功能)
3. [数据模型](#数据模型)
4. [用户界面](#用户界面)
5. [音频功能](#音频功能)
6. [进度追踪](#进度追踪)
7. [未完成功能](#未完成功能)
8. [技术栈](#技术栈)

---

## 概述

VocFr 是一个法语词汇学习 iOS 应用，帮助用户系统化地学习法语单词和短语。应用采用单元-章节-单词的三级结构组织内容，支持音频播放和学习进度追踪。

**当前版本特点**:
- 支持多种词性（名词、动词、形容词等）
- 集成音频播放和片段管理
- 基于 SwiftUI + SwiftData 构建
- 包含欢迎界面和主导航系统

---

## 核心功能

### 1. 学习模式 ✅ 已实现

#### 1.1 单元浏览（UnitsView）
- **功能**: 显示所有学习单元列表
- **特性**:
  - 显示单元编号和标题
  - 显示每个单元包含的章节数量
  - 单元解锁机制（基于星星数量）
  - 已解锁单元显示✓标记
  - 未解锁单元显示🔒图标和所需星星数
- **文件**: `VocFr/UniteView.swift:11-46`
- **导航**: 从主应用视图 → 单元列表

#### 1.2 章节浏览（SectionDetailView）
- **功能**: 显示选定单元中的所有章节
- **特性**:
  - 章节列表按顺序排序
  - 显示章节名称和单词数量
  - 点击章节进入单词列表
  - 工具栏提供"练习"快捷入口
- **文件**: `VocFr/SectionView.swift:13-38`
- **导航**: 单元列表 → 章节列表

#### 1.3 单词学习（WordView）
- **功能**: 显示单词详细信息和各种形式
- **特性**:
  - 显示单词图片
  - 显示中文翻译
  - 显示法语原文和音标
  - 显示不同形式（阳性/阴性、单数/复数）
  - 音频播放支持（完整音频 + 音频片段）
  - 上一个/下一个单词导航
  - 词性标注
- **文件**: `VocFr/WordView.swift` (571行)
- **导航**: 章节列表 → 单词详情

#### 1.4 单词练习（PracticeView）
- **功能**: 章节词汇练习模式
- **特性**:
  - 按章节进行练习
  - 支持快速开始练习
- **文件**: `VocFr/PracticeView.swift`
- **导航**: 章节详情工具栏 → 练习视图

### 2. 答题模式 🚧 开发中

#### 2.1 测试模式（TestModeView）
- **状态**: 占位符视图
- **计划功能**: 测试用户的法语水平
- **当前实现**: 仅显示"测试功能正在开发中"
- **文件**: `VocFr/TestModeView.swift:11-28`
- **导航**: 从主应用视图可访问

### 3. 游戏模式 ⏳ 未开始

#### 3.1 游戏化学习
- **状态**: 未开始开发
- **当前实现**: 主界面按钮已禁用，显示"敬请期待"
- **文件**: `VocFr/MainAppView.swift:53-59`

---

## 数据模型

### 核心模型（使用 SwiftData @Model）

#### 1. Unite（单元）
```swift
@Model class Unite
```
- **属性**:
  - `id: String` - 唯一标识符
  - `number: Int` - 单元编号
  - `title: String` - 单元标题
  - `isUnlocked: Bool` - 解锁状态
  - `requiredStars: Int` - 解锁所需星星数
- **关系**:
  - `sections: [Section]` - 包含的章节（级联删除）
- **文件**: `VocFr/Models.swift:42-59`

#### 2. Section（章节）
```swift
@Model class Section
```
- **属性**:
  - `id: String` - 唯一标识符
  - `name: String` - 章节名称
  - `orderIndex: Int` - 排序索引
- **关系**:
  - `unite: Unite?` - 所属单元
  - `sectionWords: [SectionWord]` - 章节单词关联（级联删除）
- **文件**: `VocFr/Models.swift:62-77`

#### 3. Word（单词）
```swift
@Model class Word
```
- **属性**:
  - `id: String` - 唯一标识符
  - `canonical: String` - 规范形式
  - `chinese: String` - 中文翻译
  - `imageName: String` - 图片文件名
  - `partOfSpeech: PartOfSpeech` - 词性
  - `category: String` - 类别
- **关系**:
  - `forms: [WordForm]` - 单词形式（级联删除）
  - `sectionWords: [SectionWord]` - 章节关联（级联删除）
  - `audioSegments: [AudioSegment]` - 音频片段（级联删除）
  - `wordProgresses: [WordProgress]` - 学习进度（级联删除）
- **文件**: `VocFr/Models.swift:80-108`

#### 4. WordForm（单词形式）
```swift
@Model class WordForm
```
- **属性**:
  - `formType: WordFormType` - 形式类型
  - `french: String` - 法语文本
  - `articleOnly: String?` - 仅冠词部分
  - `gender: Gender?` - 性别（阳性/阴性）
  - `number: Number?` - 数量（单数/复数）
  - `isMainForm: Bool` - 是否为主要形式
- **关系**:
  - `word: Word?` - 所属单词
- **文件**: `VocFr/Models.swift:110-129`

#### 5. SectionWord（章节-单词关联）
```swift
@Model class SectionWord
```
- **属性**:
  - `orderIndex: Int` - 单词在章节中的顺序
- **关系**:
  - `section: Section?` - 所属章节
  - `word: Word?` - 关联单词
- **文件**: `VocFr/Models.swift:132-141`

### 音频模型

#### 6. AudioFile（音频文件）
```swift
@Model class AudioFile
```
- **属性**:
  - `fileName: String` - 文件名
  - `filePath: String` - 文件路径
  - `duration: Double` - 持续时间（秒）
- **关系**:
  - `audioSegments: [AudioSegment]` - 音频片段（级联删除）
- **文件**: `VocFr/Models.swift:144-157`

#### 7. AudioSegment（音频片段）
```swift
@Model class AudioSegment
```
- **属性**:
  - `startTime: Double` - 开始时间（秒）
  - `endTime: Double` - 结束时间（秒）
  - `formType: WordFormType` - 对应的单词形式类型
  - `quality: AudioQuality` - 音质等级
  - `confidence: Double` - 置信度
- **关系**:
  - `word: Word?` - 关联单词
  - `audioFile: AudioFile?` - 所属音频文件
- **文件**: `VocFr/Models.swift:160-177`

### 进度追踪模型

#### 8. UserProgress（用户进度）
```swift
@Model class UserProgress
```
- **属性**:
  - `totalStars: Int` - 总星星数
  - `currentStreak: Int` - 当前连续学习天数
  - `lastStudyDate: Date?` - 最后学习日期
- **关系**:
  - `wordProgresses: [WordProgress]` - 单词进度（级联删除）
  - `practiceRecords: [PracticeRecord]` - 练习记录（级联删除）
- **文件**: `VocFr/Models.swift:182-198`

#### 9. WordProgress（单词进度）
```swift
@Model class WordProgress
```
- **属性**:
  - `masteryLevel: Int` - 掌握程度等级
  - `correctCount: Int` - 正确次数
  - `incorrectCount: Int` - 错误次数
  - `lastReviewed: Date?` - 最后复习日期
  - `nextReviewDate: Date?` - 下次复习日期
- **关系**:
  - `word: Word?` - 关联单词
  - `userProgress: UserProgress?` - 所属用户进度
- **文件**: `VocFr/Models.swift:201-218`

#### 10. PracticeRecord（练习记录）
```swift
@Model class PracticeRecord
```
- **属性**:
  - `sessionDate: Date` - 练习日期
  - `sessionType: String` - 练习类型
  - `wordsStudied: Int` - 学习单词数
  - `accuracy: Double` - 准确率
  - `timeSpent: TimeInterval` - 花费时间
- **关系**:
  - `userProgress: UserProgress?` - 所属用户进度
- **文件**: `VocFr/Models.swift:221-237`

### 枚举类型

```swift
enum PartOfSpeech: String, Codable
    - noun = "名词"
    - verb = "动词"
    - adjective = "形容词"
    - number = "数词"
    - pronoun = "代词"
    - preposition = "介词"
    - other = "其他"

enum WordFormType: String, Codable
    - indefiniteArticle = "不定冠词"
    - definiteArticle = "定冠词"
    - withElision = "省音形式"
    - baseForm = "基本形式"

enum Gender: String, Codable
    - masculine = "阳性"
    - feminine = "阴性"

enum Number: String, Codable
    - singular = "单数"
    - plural = "复数"

enum AudioQuality: String, Codable
    - high = "高质量"
    - normal = "普通"
    - low = "低质量"
```
**文件**: `VocFr/Models.swift:6-37`

---

## 用户界面

### 1. 欢迎界面（WelcomeView）✅
- **功能**: 应用首次启动时的欢迎页面
- **组件**:
  - 应用图标和标题
  - 三个特性介绍行
    - 丰富课程
    - 音频练习
    - 学习进度
  - "开始学习"按钮（带动画过渡）
- **设计**:
  - 渐变背景
  - 蓝色主题
  - 阴影效果
- **文件**: `VocFr/WelcomeView.swift:10-83`
- **触发**: 应用首次启动时显示

### 2. 主应用界面（MainAppView）✅
- **功能**: 主导航中心，提供三种学习模式入口
- **组件**:
  - 导航标题："法语学习"
  - 侧边栏菜单按钮（左上角）
  - 三个模式按钮（堆积式布局）:
    - 学习模式（蓝色，已启用）
    - 答题模式（绿色，已启用）
    - 游戏模式（紫色，禁用状态）
- **设计**:
  - 每个按钮包含图标、标题、描述
  - 已禁用模式显示灰色
  - 已启用模式显示向右箭头
- **文件**: `VocFr/MainAppView.swift:10-79`
- **导航**: 欢迎界面 → 主应用界面

### 3. 单词行视图（WordRowView）✅
- **功能**: 在列表中显示单词条目
- **显示内容**:
  - 单词图片（50x50）
  - 法语文本
  - 中文翻译
  - 词性标签
- **文件**: `VocFr/WordRowView.swift`

### 4. 菜单视图（MenuView）
- **功能**: 侧边栏菜单
- **文件**: `VocFr/MenuView.swift`
- **触发**: 点击主界面左上角菜单按钮

### 5. 设置视图（SettingsView）
- **功能**: 应用设置
- **文件**: `VocFr/SettingsView.swift`

### 6. 进度视图（ProgressView）
- **功能**: 显示学习进度和统计
- **文件**: `VocFr/ProgressView.swift`

---

## 音频功能

### AudioPlayerManager（音频播放管理器）✅

**单例模式**: `AudioPlayerManager.shared`

#### 功能特性

1. **完整音频播放** (`playAudio`)
   - 播放完整的音频文件
   - 自动解析多种音频格式（wav, mp3, m4a, aac）
   - 支持带扩展名或不带扩展名的文件名
   - **文件**: `VocFr/AudioPlayerManager.swift:29-53`

2. **音频片段播放** (`playAudioSegment`)
   - 播放指定时间段的音频片段
   - 支持精确的开始/结束时间控制
   - 使用 Timer 确保在指定时间停止播放
   - **文件**: `VocFr/AudioPlayerManager.swift:55-90`

3. **播放控制**
   - `stopAudio()`: 停止当前播放
   - `togglePlayback()`: 切换播放/暂停状态
   - **文件**: `VocFr/AudioPlayerManager.swift:117-140`

4. **状态管理**
   - `@Published var isPlaying: Bool` - 播放状态（支持 SwiftUI 响应式更新）
   - 完成回调机制
   - **文件**: `VocFr/AudioPlayerManager.swift:8`

5. **音频会话配置**
   - 自动配置 AVAudioSession
   - 播放类别设置
   - **文件**: `VocFr/AudioPlayerManager.swift:20-27`

6. **错误处理**
   - 音频解码错误处理（AVAudioPlayerDelegate）
   - 文件未找到错误处理
   - 播放失败回调
   - **文件**: `VocFr/AudioPlayerManager.swift:156-167`

#### 资源解析机制

**支持的音频格式**:
- WAV (.wav)
- MP3 (.mp3)
- AAC (.aac)
- M4A (.m4a)

**解析策略** (`resolveURL`):
1. 如果提供了扩展名，优先尝试该扩展名
2. 否则按顺序尝试所有支持的格式
3. 从 Bundle.main 中查找资源
- **文件**: `VocFr/AudioPlayerManager.swift:95-115`

---

## 进度追踪

### 已实现的进度系统 ✅

1. **单词级别追踪** (WordProgress)
   - 掌握程度等级
   - 正确/错误计数
   - 最后复习时间
   - 下次复习时间（间隔重复学习算法基础）

2. **用户总体进度** (UserProgress)
   - 总星星数
   - 连续学习天数（streak）
   - 最后学习日期

3. **练习记录** (PracticeRecord)
   - 练习会话日期
   - 练习类型
   - 学习单词数
   - 准确率
   - 花费时间

### 待实现的功能 🚧

- 星星奖励机制的具体逻辑
- 解锁系统的触发条件
- 间隔重复学习算法（SRS）
- 进度可视化图表

---

## 未完成功能

### 高优先级 🔴

1. **答题模式完整实现**
   - 当前仅有占位符视图
   - 需要实现测试题目生成
   - 需要实现答题逻辑和评分系统

2. **数据播种优化**
   - `FrenchWord.swift` 文件过大（1,462行）
   - 需要提取到 JSON 数据文件
   - 需要优化初始化性能

3. **音频时间戳完整性**
   - 需要为所有单词添加音频片段时间戳
   - 需要验证音频文件完整性

### 中优先级 🟡

4. **游戏模式**
   - 当前完全未开始
   - 需要设计游戏化学习机制

5. **设置功能**
   - 音频设置
   - 学习偏好设置
   - 数据管理（导入/导出）

6. **菜单功能完善**
   - 关于页面
   - 帮助文档
   - 反馈渠道

### 低优先级 🟢

7. **UI/UX 增强**
   - 深色模式支持
   - 动画效果优化
   - 无障碍功能

8. **离线功能**
   - 音频预加载
   - 离线数据同步

---

## 技术栈

### 框架和库

| 技术 | 版本 | 用途 |
|------|------|------|
| SwiftUI | iOS 18.0+ | UI 框架 |
| SwiftData | iOS 18.0+ | 数据持久化 |
| AVFoundation | iOS 18.0+ | 音频播放 |
| Combine | iOS 18.0+ | 响应式编程 |

### 架构模式

- **当前**: 混合架构（部分 MVC，部分直接视图逻辑）
- **目标**: MVVM + Dependency Injection
- **数据层**: SwiftData (ORM)

### 项目结构

```
VocFr/
├── VocFr/
│   ├── Models.swift                    (248行 - 所有模型定义)
│   ├── FrenchWord.swift               (1,462行 - 数据播种)
│   ├── VocFrApp.swift                  (64行 - 应用入口)
│   ├── ContentView.swift               (36行 - 根视图)
│   ├── WelcomeView.swift              (114行 - 欢迎界面)
│   ├── MainAppView.swift              (129行 - 主导航)
│   ├── UniteView.swift                (119行 - 单元视图)
│   ├── SectionView.swift               (52行 - 章节视图)
│   ├── WordView.swift                 (571行 - 单词详情)
│   ├── WordRowView.swift               - 单词列表项
│   ├── WordListView.swift              - 单词列表
│   ├── PracticeView.swift              - 练习视图
│   ├── TestModeView.swift              (34行 - 测试模式占位符)
│   ├── MenuView.swift                  - 菜单
│   ├── SettingsView.swift              - 设置
│   ├── ProgressView.swift              - 进度
│   ├── AudioPlayerManager.swift       (169行 - 音频管理)
│   └── SimpleModelTests.swift          - 简单测试
├── VocFrTests/
│   └── VocFrTests.swift               - 单元测试
├── VocFrUITests/
│   ├── VocFrUITests.swift             - UI测试
│   └── VocFrUITestsLaunchTests.swift  - 启动测试
└── Assets/
    ├── Images/                         - 单词图片
    └── Audio/                          - 音频文件
```

**总代码行数**: 约 4,089 行（估算）

---

## 数据播种系统

### FrenchVocabularySeeder ✅

**文件**: `VocFr/FrenchWord.swift:1-1462`

#### 主要功能

1. **seedAllData(to context: ModelContext)**
   - 创建单元（Unite）
   - 创建章节（Section）
   - 创建单词（Word）及其形式（WordForm）
   - 建立章节-单词关联（SectionWord）
   - 初始化用户进度（UserProgress）

2. **addAudioTimestamps(to context: ModelContext)**
   - 为单词添加音频片段时间戳
   - 关联音频文件和单词

3. **validateData(from context: ModelContext) -> [String]**
   - 验证数据完整性
   - 返回验证问题列表

4. **generateDataReport(from context: ModelContext) -> String**
   - 生成数据统计报告
   - 显示单元、章节、单词数量

#### 已播种的数据（Unité 1）

**章节列表**:
1. Bonjour !（你好！）
2. Ça va ?（你好吗？）
3. Au Revoir !（再见！）
4. Les nombres（数字）
5. Les personnes（人物）
6. Être（动词"是"）

**数据规模**:
- 单元数: 1
- 章节数: 6
- 单词数: 约 50-80 个（估算）

---

## 测试覆盖

### 单元测试 🚧
- **文件**: `VocFrTests/VocFrTests.swift`
- **状态**: 基础测试框架已建立
- **覆盖率**: 待测量

### UI 测试 🚧
- **文件**: `VocFrUITests/VocFrUITests.swift`
- **状态**: 基础测试框架已建立
- **覆盖率**: 待测量

### 简单模型测试 ✅
- **文件**: `VocFr/SimpleModelTests.swift`
- **状态**: 存在但待验证

---

## 性能基准

### 当前性能指标（待测量）

| 指标 | 当前值 | 目标值 | 状态 |
|------|--------|--------|------|
| 应用启动时间 | TBM | < 2s | 🔄 |
| 数据播种时间 | TBM | < 3s | 🔄 |
| 单词视图加载 | TBM | < 0.5s | 🔄 |
| 音频播放延迟 | TBM | < 0.3s | 🔄 |
| 内存占用 | TBM | < 50MB | 🔄 |

**TBM** = To Be Measured (待测量)

---

## 已知问题

### 架构问题 🔴

1. **文件组织混乱**
   - 所有文件在同一目录下
   - 缺少逻辑分组（Models/, Views/, ViewModels/, Services/）
   - **影响**: 可维护性差

2. **单一职责原则违反**
   - `WordView.swift` (571行) - 太大
   - `FrenchWord.swift` (1,462行) - 太大
   - **影响**: 难以维护和测试

3. **缺少 ViewModel 层**
   - 视图直接访问 SwiftData 模型
   - 业务逻辑和 UI 逻辑混合
   - **影响**: 难以测试，耦合度高

4. **缺少依赖注入**
   - `AudioPlayerManager.shared` 使用单例
   - 难以进行单元测试
   - **影响**: 测试困难

### 功能问题 🟡

5. **音频时间戳不完整**
   - 仅部分单词有音频片段数据
   - **影响**: 音频播放功能不完整

6. **解锁机制未实现**
   - 单元解锁条件定义但未触发
   - **影响**: 进度系统不完整

7. **测试覆盖率低**
   - 缺少关键功能的单元测试
   - **影响**: 重构风险高

---

## 重构优先级

根据 `REFACTORING_PLAN.md` 规划，建议按以下顺序进行重构：

### Phase 0: 准备工作 ✅ 进行中
- ✅ 创建 refactoring 分支
- 🔄 文档化当前功能（本文档）
- ⏳ 建立基准测试

### Phase 1: 文件组织（1-2天）
- 创建目录结构
- 移动文件到对应目录
- 更新所有 import 语句

### Phase 2: 数据层重构（2-3天）
- 提取 JSON 数据文件
- 创建数据服务层
- 优化数据加载

### Phase 3: MVVM 架构（3-5天）
- 创建 ViewModel 层
- 分离业务逻辑和 UI 逻辑
- 重构大型视图文件

### Phase 4: 依赖注入和测试（2-3天）
- 实现依赖注入容器
- 编写单元测试
- 提高测试覆盖率

### Phase 5: 优化和完善（2-3天）
- 性能优化
- UI/UX 改进
- 文档完善

---

## 附录

### A. 关键文件清单

| 文件 | 行数 | 类型 | 优先级 |
|------|------|------|--------|
| FrenchWord.swift | 1,462 | 数据 | 🔴 高 |
| WordView.swift | 571 | 视图 | 🔴 高 |
| Models.swift | 248 | 模型 | 🟡 中 |
| AudioPlayerManager.swift | 169 | 服务 | 🟡 中 |
| MainAppView.swift | 129 | 视图 | 🟢 低 |
| UniteView.swift | 119 | 视图 | 🟢 低 |
| WelcomeView.swift | 114 | 视图 | 🟢 低 |
| VocFrApp.swift | 64 | 配置 | 🟢 低 |
| SectionView.swift | 52 | 视图 | 🟢 低 |
| ContentView.swift | 36 | 视图 | 🟢 低 |
| TestModeView.swift | 34 | 视图 | 🟡 中 |

### B. 数据模型关系图

```
Unite (单元)
  └─ sections: [Section]
        └─ sectionWords: [SectionWord]
              └─ word: Word
                    ├─ forms: [WordForm]
                    ├─ audioSegments: [AudioSegment]
                    │     └─ audioFile: AudioFile
                    └─ wordProgresses: [WordProgress]
                          └─ userProgress: UserProgress
                                └─ practiceRecords: [PracticeRecord]
```

### C. 视图导航层次

```
ContentView
  ├─ WelcomeView (首次启动)
  └─ MainAppView (主界面)
        ├─ UnitsView (学习模式)
        │     └─ UniteDetailView
        │           └─ SectionDetailView
        │                 ├─ WordDetailView
        │                 └─ PracticeView
        ├─ TestModeView (答题模式)
        └─ MenuView (侧边栏)
              ├─ SettingsView
              └─ ProgressView
```

---

## 变更历史

| 日期 | 版本 | 变更描述 | 作者 |
|------|------|----------|------|
| 2025-11-11 | 1.0 | 初始文档创建 | Claude |

---

**文档结束**
